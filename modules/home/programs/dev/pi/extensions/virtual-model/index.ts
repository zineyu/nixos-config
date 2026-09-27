import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import {
	createAssistantMessageEventStream,
	type Api,
	type AssistantMessageEvent,
	type AssistantMessageEventStream,
	type Model,
	type SimpleStreamOptions,
	type TranscriptContext,
} from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

// 虚拟模型 provider：每个虚拟模型对应一个按优先级排序的真实模型列表，
// 单次请求内从最高优先级开始依次尝试，首个成功输出内容的候选生效。
// 仅在流开始输出内容之前失败才切换下一个候选；用户取消（abort）直接传播。

const PROVIDER_NAME = "virtual";
const CONFIG_PATH = join(homedir(), ".pi", "agent", "virtual-models.json");

const DEFAULT_CONTEXT_WINDOW = 200_000;
const DEFAULT_MAX_TOKENS = 16_384;

interface CandidateRef {
	provider: string;
	modelId: string;
}

interface VirtualModelDef {
	id: string;
	name: string;
	candidates: CandidateRef[];
	reasoning: boolean;
	input: ("text" | "image")[];
	contextWindow: number;
	maxTokens: number;
}

type RelayOutcome =
	| { kind: "committed" }
	| { kind: "aborted" }
	| { kind: "failed"; message: string };

function errorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}

function parseCandidate(raw: unknown, virtualId: string): CandidateRef {
	if (typeof raw !== "string") {
		throw new Error(`virtual-model: 模型 "${virtualId}" 的 candidates 元素必须是字符串`);
	}
	const slash = raw.indexOf("/");
	if (slash <= 0 || slash === raw.length - 1) {
		throw new Error(`virtual-model: 模型 "${virtualId}" 的候选 "${raw}" 必须是 provider/model 形式`);
	}
	return { provider: raw.slice(0, slash), modelId: raw.slice(slash + 1) };
}

function readPositiveInt(entry: Record<string, unknown>, key: string, virtualId: string): number | undefined {
	const value = entry[key];
	if (value === undefined) return undefined;
	if (typeof value !== "number" || !Number.isInteger(value) || value <= 0) {
		throw new Error(`virtual-model: 模型 "${virtualId}" 的 ${key} 必须是正整数`);
	}
	return value;
}

function readInput(entry: Record<string, unknown>, virtualId: string): ("text" | "image")[] {
	const value = entry.input;
	if (value === undefined) return ["text"];
	if (
		!Array.isArray(value) ||
		value.length === 0 ||
		!value.every((item) => item === "text" || item === "image")
	) {
		throw new Error(`virtual-model: 模型 "${virtualId}" 的 input 必须是非空的 "text"/"image" 数组`);
	}
	return value;
}

function loadVirtualModels(): Map<string, VirtualModelDef> {
	const parsed: unknown = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
	if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
		throw new Error(`virtual-model: ${CONFIG_PATH} 顶层必须是对象`);
	}
	const models = (parsed as Record<string, unknown>).models;
	if (typeof models !== "object" || models === null || Array.isArray(models)) {
		throw new Error(`virtual-model: ${CONFIG_PATH} 缺少 "models" 对象`);
	}

	const defs = new Map<string, VirtualModelDef>();
	for (const [id, entryRaw] of Object.entries(models)) {
		if (typeof entryRaw !== "object" || entryRaw === null || Array.isArray(entryRaw)) {
			throw new Error(`virtual-model: 模型 "${id}" 的配置必须是对象`);
		}
		const entry = entryRaw as Record<string, unknown>;
		if (!Array.isArray(entry.candidates) || entry.candidates.length === 0) {
			throw new Error(`virtual-model: 模型 "${id}" 的 candidates 必须是非空数组`);
		}
		defs.set(id, {
			id,
			name: typeof entry.name === "string" ? entry.name : id,
			candidates: entry.candidates.map((raw) => parseCandidate(raw, id)),
			reasoning: entry.reasoning === true,
			input: readInput(entry, id),
			contextWindow: readPositiveInt(entry, "contextWindow", id) ?? DEFAULT_CONTEXT_WINDOW,
			maxTokens: readPositiveInt(entry, "maxTokens", id) ?? DEFAULT_MAX_TOKENS,
		});
	}
	return defs;
}

function pushTerminalError(
	stream: AssistantMessageEventStream,
	model: Model<Api>,
	message: string,
	reason: "error" | "aborted" = "error",
): void {
	stream.push({
		type: "error",
		reason,
		error: {
			role: "assistant",
			content: [],
			api: model.api,
			provider: model.provider,
			model: model.id,
			usage: {
				input: 0,
				output: 0,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 0,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			},
			stopReason: reason,
			errorMessage: message,
			timestamp: Date.now(),
		},
	});
	stream.end();
}

// 转发候选模型的事件流。首个内容事件之前的事件先缓冲：若候选在输出内容前失败，
// 返回 failed 由调用方切换下一个候选；一旦开始输出内容即提交该候选，
// 之后的事件（包括 error）原样转发。
async function relay(
	inner: AssistantMessageEventStream,
	outer: AssistantMessageEventStream,
): Promise<RelayOutcome> {
	const buffered: AssistantMessageEvent[] = [];
	let committed = false;

	for await (const event of inner) {
		if (event.type === "error") {
			if (!committed && event.reason !== "aborted") {
				return { kind: "failed", message: event.error.errorMessage ?? "未知错误" };
			}
			for (const pending of buffered) outer.push(pending);
			outer.push(event);
			outer.end();
			return { kind: event.reason === "aborted" ? "aborted" : "committed" };
		}
		if (!committed) {
			buffered.push(event);
			if (event.type !== "start") {
				for (const pending of buffered) outer.push(pending);
				buffered.length = 0;
				committed = true;
			}
		} else {
			outer.push(event);
		}
		if (event.type === "done") {
			outer.end();
			return { kind: "committed" };
		}
	}

	if (committed) {
		outer.end();
		return { kind: "committed" };
	}
	return { kind: "failed", message: "流在未产生终止事件的情况下结束" };
}

function streamVirtual(
	def: VirtualModelDef,
	getCtx: () => ExtensionContext | undefined,
	model: Model<Api>,
	context: TranscriptContext,
	options: SimpleStreamOptions | undefined,
): AssistantMessageEventStream {
	const stream = createAssistantMessageEventStream();

	(async () => {
		const ctx = getCtx();
		if (!ctx) {
			pushTerminalError(stream, model, `virtual/${def.id}: 没有活动的会话上下文`);
			return;
		}

		const failures: string[] = [];
		for (let index = 0; index < def.candidates.length; index++) {
			const ref = def.candidates[index];
			const target = `${ref.provider}/${ref.modelId}`;

			if (options?.signal?.aborted) {
				pushTerminalError(stream, model, "请求已取消", "aborted");
				return;
			}

			const realModel = ctx.modelRegistry.find(ref.provider, ref.modelId);
			if (!realModel) {
				failures.push(`${target}: 模型未注册`);
				continue;
			}

			let outcome: RelayOutcome;
			try {
				const inner = ctx.modelRegistry.streamSimple(realModel, context, options);
				outcome = await relay(inner, stream);
			} catch (error) {
				outcome = { kind: "failed", message: errorMessage(error) };
			}
			if (outcome.kind === "committed" || outcome.kind === "aborted") return;

			failures.push(`${target}: ${outcome.message}`);
			const next = def.candidates[index + 1];
			if (next && ctx.hasUI) {
				ctx.ui.notify(
					`virtual/${def.id}: ${target} 失败，切换 ${next.provider}/${next.modelId}`,
					"warning",
				);
			}
		}

		pushTerminalError(stream, model, `virtual/${def.id}: 所有候选模型均失败\n${failures.join("\n")}`);
	})().catch((error: unknown) => {
		pushTerminalError(stream, model, `virtual/${def.id}: ${errorMessage(error)}`);
	});

	return stream;
}

export default function (pi: ExtensionAPI) {
	const defs = loadVirtualModels();
	if (defs.size === 0) return;

	let sessionCtx: ExtensionContext | undefined;
	pi.on("session_start", (_event, ctx) => {
		sessionCtx = ctx;
	});

	pi.registerProvider(PROVIDER_NAME, {
		name: "Virtual",
		// baseUrl 与 apiKey 仅用于通过注册校验；虚拟 provider 自身不发送请求，
		// 每个候选真实模型的端点与凭证由 modelRegistry 在请求时解析。
		baseUrl: "http://virtual.invalid/",
		apiKey: "virtual",
		api: "virtual",
		models: [...defs.values()].map((def) => ({
			id: def.id,
			name: def.name,
			reasoning: def.reasoning,
			input: def.input,
			cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
			contextWindow: def.contextWindow,
			maxTokens: def.maxTokens,
		})),
		streamSimple: (model, context, options) => {
			const def = defs.get(model.id);
			if (!def) throw new Error(`virtual-model: 未注册的模型 "${model.id}"`);
			return streamVirtual(def, () => sessionCtx, model, context, options);
		},
	});
}
