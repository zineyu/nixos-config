/**
 * notebook + handoff primitives for pi, extracted from pi-schematic
 * (https://github.com/chunkhound/pi-schematic, formerly agenticoding/pi-agenticoding).
 *
 * Wires together:
 *   notebook — durable cross-context memory (notebook_write/read/index + topic)
 *   handoff  — deliberate task pivot via compaction
 *
 * Also registers:
 *   - watchdog (topic-aware context-pressure reminder after each turn)
 *   - system prompt injection (CONTEXT_PRIMER, active topic, notebook listing)
 *   - state reset on /new, branch-scoped notebook rehydration, successor recovery
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import {
	Container,
	type SelectItem,
	SelectList,
	Text,
	type TUI,
} from "@earendil-works/pi-tui";
import { createState, invalidateHandoffState, resetState, type SchematicState } from "./state.js";
import { CONTEXT_PRIMER } from "./system-prompt.js";
import { buildNudge, registerWatchdog } from "./watchdog.js";
import { registerNotebookTools } from "./notebook/tools.js";
import { ensureNotebookToolsActive, registerNotebookRehydration, reconstructNotebook } from "./notebook/rehydration.js";
import { registerNotebookTopicTool } from "./notebook/topic-tool.js";
import { setActiveNotebookTopic } from "./notebook/topic.js";
import { formatPageTuiPreview } from "./notebook/store.js";
import { openInPager, pagerRuntime, type ResolvedPager } from "./notebook/pager.js";
import { registerHandoffTool } from "./handoff/tool.js";
import { isHandoffEligible, normalizeContextPercent } from "./handoff/eligibility.js";
import { HANDOFF_REQUIRED_STATUS } from "./handoff/copy.js";
import { registerHandoffCommand } from "./handoff/command.js";
import { registerHandoffCompaction } from "./handoff/compact.js";
import { getUndeliveredHandoffMessage } from "./handoff/recovery.js";
import { sendFollowUp } from "./follow-up.js";
import {
	STATUS_KEY_HANDOFF,
	STATUS_KEY_TOPIC,
	WIDGET_KEY_WARNING,
	updateIndicators,
} from "./tui.js";

export default function (pi: ExtensionAPI): void {
	const state: SchematicState = createState();

	// ── Register all tools ──────────────────────────────────────────
	registerNotebookTools(pi, state);
	registerNotebookTopicTool(pi, state);
	registerHandoffTool(pi, state);

	// ── Register event handlers ─────────────────────────────────────
	registerWatchdog(pi, state);
	registerNotebookRehydration(pi, state);
	registerHandoffCompaction(pi, state);

	// ── Register commands ───────────────────────────────────────────
	registerHandoffCommand(pi, state);

	function recoverHandoffMessage(ctx: ExtensionContext): void {
		// Never fight an in-flight cut: the compaction hook owns the reservation and
		// will deliver its own payload on completion.
		if (state.handoffCompactionGeneration !== null) return;
		// A queued follow-up may be the successor message itself, not yet persisted;
		// resending now would double-deliver once the queue drains.
		if (ctx.hasPendingMessages()) return;
		const branch = ctx.sessionManager.getBranch();
		const candidate = getUndeliveredHandoffMessage(branch, ctx.sessionManager.getEntries());
		// The latch coalesces repeated triggers for one persisted cut. New cuts carry a
		// durable recovery key; legacy cuts fall back to their persisted entry identity.
		if (!candidate) return;
		const requested = state.recoveryRequestedMessage;
		if (requested?.message === candidate.message &&
			((candidate.recoveryKey !== null && requested.recoveryKey === candidate.recoveryKey) ||
				(candidate.recoveryKey === null && requested.handoffEntryId === candidate.handoffEntryId))) {
			requested.handoffEntryId = candidate.handoffEntryId;
			return;
		}
		state.recoveryRequestedMessage = candidate;
		try {
			sendFollowUp(pi, candidate.message);
		} catch (error) {
			state.recoveryRequestedMessage = null;
			if (ctx.hasUI) {
				const message = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(`Handoff recovery delivery failed: ${message}. It will retry when the session settles.`, "error");
			}
			throw error;
		}
	}

	// ── /notebook command — interactive page selector ────────────────
	pi.registerCommand("notebook", {
		description: "Select a notebook page to view, or set the active notebook topic with /notebook <topic>",
		handler: async (args, ctx) => {
			const topicArg = args.trim();
			if (topicArg) {
				const result = setActiveNotebookTopic(state, topicArg, "human");
				if (ctx.hasUI) {
					ctx.ui.notify(result.boundaryHint
						? `Active notebook topic changed: ${result.boundaryHint.from} → ${result.boundaryHint.to}. This is a likely task boundary; handoff is recommended before continuing.`
						: `Active notebook topic: ${result.current}`,
						result.boundaryHint ? "warning" : "info");
				}
				updateIndicators(ctx, state);
				return;
			}
			if (!ctx.hasUI) {
				return;
			}

			let lastSelectedName: string | undefined;
			// Resolve once per /notebook so onSelect doesn't run `command -v less` on every Enter.
			const pager = pagerRuntime.resolvePager();
			while (true) {
				// Pi has no extension API to suspend the TUI, so the "pager" result carries
				// custom()'s handle for openInPager, which runs after done() closes the list.
				// It is Pi's long-lived TUI reference, so it stays valid past done().
				const result = await ctx.ui.custom<
					| { action: "pager"; name: string; body: string; tui: TUI; pager: ResolvedPager }
					| { action: "reopen"; name: string }
					| undefined
				>((tui, theme, _kb, done) => {
					const container = new Container();

					container.addChild(
						new DynamicBorder((s: string) => theme.fg("accent", s)),
					);
					container.addChild(
						new Text(theme.fg("accent", theme.bold(` Notebook (${state.notebookPages.size} pages) `)), 1, 0),
					);

					const entries = Array.from(state.notebookPages.entries()).sort(([a], [b]) => a.localeCompare(b));
					let selectList: SelectList | undefined;
					let previewName: string | undefined;
					let finished = false;

					if (entries.length === 0) {
						container.addChild(
							new Text(theme.fg("dim", " (empty) — use notebook_write to create pages"), 1, 0),
						);
					} else {
						const items: SelectItem[] = entries.map(([name, content]) => ({
							value: name,
							label: name,
							description: formatPageTuiPreview(content, state.clippedPages.has(name)),
						}));

						selectList = new SelectList(items, Math.min(items.length, 10), {
							selectedPrefix: (t) => theme.fg("accent", t),
							selectedText: (t) => theme.fg("accent", t),
							description: (t) => theme.fg("muted", t),
							scrollInfo: (t) => theme.fg("dim", t),
							noMatch: (t) => theme.fg("warning", t),
						});
						if (lastSelectedName !== undefined) {
							const idx = items.findIndex((it) => it.value === lastSelectedName);
							if (idx >= 0) selectList.setSelectedIndex(idx);
						}
						selectList.onSelect = ({ value }) => {
							const body = state.notebookPages.get(value);
							// A handoff discard can commit while the list is open (its compaction finishes in the background).
							if (body === undefined) {
								finished = true;
								done({ action: "reopen", name: value });
								return;
							}
							// Prefer a real pager when available; else fall back to a
							// truncated inline preview.
							if (pager) {
								finished = true;
								done({ action: "pager", name: value, body, tui, pager });
								return;
							}
							container.clear();
							container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));
							container.addChild(new Text(theme.fg("accent", theme.bold(` ${value} `)), 1, 0));
							const truncated = body.length > 500;
							container.addChild(new Text(theme.fg("toolOutput", truncated ? body.slice(0, 500) : body), 1, 0));
							if (truncated) container.addChild(new Text(theme.fg("dim", " ... set $PI_PAGER to a full-screen pager (e.g. less) to view the full page "), 1, 0));
							container.addChild(new Text(theme.fg("dim", " any key back "), 1, 0));
							container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));
							previewName = value;
							selectList = undefined;
							tui.requestRender();
						};
						selectList.onCancel = () => {
							if (finished) return;
							finished = true;
							done(undefined);
						};
						container.addChild(selectList);
					}

					container.addChild(
						new Text(theme.fg("dim", entries.length === 0
							? " esc close "
							: " \u2191\u2195 navigate \u2022 enter view \u2022 esc close "), 1, 0),
					);
					container.addChild(
						new DynamicBorder((s: string) => theme.fg("accent", s)),
					);

					return {
						render: (w) => container.render(w),
						invalidate: () => container.invalidate(),
						handleInput: (data) => {
							if (finished) return;
							if (!selectList) {
								// Any key leaves the inline preview (back to the list) or the empty notebook.
								finished = true;
								done(previewName === undefined ? undefined : { action: "reopen", name: previewName });
								return;
							}
							selectList.handleInput?.(data);
							// Conservative: always repaint after key input.
							// SelectList.handleInput returns void in the current API,
							// so we can't conditionally skip — the cost is negligible.
							tui.requestRender();
						},
					};
				});
				if (!result) return;
				lastSelectedName = result.name;
				if (result.action === "pager") {
					const err = await openInPager(result.tui, result.body, result.pager);
					if (err) ctx.ui.notify(`pager failed: ${err.message}`, "warning");
				}
			}
		},
	});

	// ── before_agent_start: inject context primer, topic, notebook listing ──
	pi.on("before_agent_start", async (event, ctx: ExtensionContext) => {
		// Update TUI indicators before each user-prompt agent run
		updateIndicators(ctx, state);

		const parts: string[] = [event.systemPrompt];

		// Inject context management primer at the end of the system prompt
		parts.push("\n" + CONTEXT_PRIMER);

		if (state.activeNotebookTopic) {
			parts.push(
				`\n## Active Notebook Topic\n` +
				`Current topic: \`${state.activeNotebookTopic}\` (${state.activeNotebookTopicSource ?? "unknown"}-set).\n` +
				`Treat this as the current semantic frame. If new work fits it, continue inline. If it does not fit it, prefer handoff.`,
			);
		} else {
			parts.push(
				`\n## Active Notebook Topic\n` +
				`No active notebook topic is set. Early in the next substantive task, assign a short stable topic with \`notebook_topic_set\`. Human-set topics are authoritative.`,
			);
		}

		// Inject notebook listing so the LLM always knows what's available
		const entryNames = Array.from(state.notebookPages.keys()).sort();
		if (entryNames.length > 0) {
			const listing = entryNames
				.map((name) => {
					const content = state.notebookPages.get(name)!;
					const firstLine = (content.split("\n")[0] ?? "").slice(0, 80);
					return `  ${name}: ${firstLine}`;
				})
				.join("\n");
			parts.push(
				`\n## Active Notebook Pages\n` +
					`The following pages are available via notebook_read by name:\n${listing}\n` +
					`Reference pages by name — never paste bodies into prompts.`,
			);
		}

		return { systemPrompt: parts.join("\n\n") };
	});

	// ── context: inject the watchdog nudge before every LLM call ─────
	// Bands: null (<30), 0 (30-49), 1 (50-69), 2 (70+). Nudges only fire when
	// crossing into a higher band, unless a topic boundary or a sticky
	// user-requested handoff keeps them active.
	pi.on("context", async (event, ctx: ExtensionContext) => {
		const usage = ctx.getContextUsage();
		const percent = normalizeContextPercent(usage?.percent);
		state.lastContextPercent = percent;

		const requestedHandoff = state.pendingRequestedHandoff;
		const mustEnforceRequestedHandoff = requestedHandoff !== null;
		if (
			requestedHandoff &&
			!requestedHandoff.toolCalled &&
			isHandoffEligible(usage) &&
			ctx.hasUI &&
			ctx.ui.theme
		) {
			ctx.ui.setStatus(
				STATUS_KEY_HANDOFF,
				ctx.ui.theme.fg("accent", HANDOFF_REQUIRED_STATUS),
			);
		}

		// Below primacy-zone threshold (~30%), skip the watchdog unless a boundary
		// hint or a sticky user-requested handoff is pending — context is still
		// fresh enough that ordinary nudges add noise.
		if (!mustEnforceRequestedHandoff && !state.pendingTopicBoundaryHint && (percent === null || percent < 30)) {
			state.lastWatchdogBand = null;
			return;
		}

		if (!mustEnforceRequestedHandoff && !state.pendingTopicBoundaryHint) {
			const band = percent! < 50 ? 0 : percent! < 70 ? 1 : 2;
			if (state.lastWatchdogBand !== null && band <= state.lastWatchdogBand) {
				return;
			}
			state.lastWatchdogBand = band;
		}

		const nudge = buildNudge(state, percent, isHandoffEligible(usage));
		state.pendingTopicBoundaryHint = null;
		return {
			messages: [
				...event.messages,
				{
					role: "custom",
					customType: "pi-schematic-watchdog",
					content: nudge,
					display: false,
					timestamp: Date.now(),
				},
			],
		};
	});

	// ── session_start: reset state on /new, recover a lost successor ──
	pi.on("session_start", async (event, ctx: ExtensionContext) => {
		if (event.reason === "new") {
			resetState(state);
			// Clear any stale TUI indicators from the previous session
			if (ctx.hasUI) {
				ctx.ui.setStatus(STATUS_KEY_HANDOFF, undefined);
				ctx.ui.setStatus(STATUS_KEY_TOPIC, undefined);
				ctx.ui.setWidget(WIDGET_KEY_WARNING, undefined);
			}
		}

		// A session start is a fresh delivery scope; drop any latch carried over from
		// an in-process resume before scanning the newly active branch.
		state.recoveryRequestedMessage = null;
		recoverHandoffMessage(ctx);
		updateIndicators(ctx, state);
	});

	// ── session_tree: invalidate branch-local handoff work, then rehydrate
	//    the branch-scoped notebook state ──
	pi.on("session_tree", async (_event, ctx: ExtensionContext) => {
		invalidateHandoffState(state);
		if (ctx.hasUI) ctx.ui.setStatus(STATUS_KEY_HANDOFF, undefined);
		// Notebook persistence is branch-scoped: pages, the committed epoch, and
		// the discard watermark follow the branch the user navigated to. Reconstruction
		// runs immediately after invalidation, so the watermark derived from the new
		// branch replaces the in-memory value before any retry could reuse a staged
		// epoch from the abandoned branch.
		reconstructNotebook(state, ctx.sessionManager.getBranch());
		ensureNotebookToolsActive(pi);
		recoverHandoffMessage(ctx);
		updateIndicators(ctx, state);
	});

	// A failed fire-and-forget successor follow-up has no extension-visible error or
	// acknowledgement. Once a later agent run settles with no queued messages, inspect
	// the persisted branch and resend only when no user turn follows the cut (a
	// delivered successor or newer user input ends recovery).
	pi.on("agent_settled", async (_event, ctx: ExtensionContext) => {
		// A settle is the retry boundary: the earlier request either landed (the branch
		// now shows it) or failed silently (still absent). Clear the latch so an absent
		// successor is retried, while repeats before the run settles stay coalesced.
		state.recoveryRequestedMessage = null;
		recoverHandoffMessage(ctx);
	});

	// ── update TUI indicators after each turn ───────────────────────
	pi.on("turn_end", async (_event, ctx: ExtensionContext) => {
		updateIndicators(ctx, state);
	});
}
