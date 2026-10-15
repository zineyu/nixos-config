/**
 * background-task 扩展 — 不阻塞对话的一次性后台任务。
 *
 * - 每个任务以 login shell 一次性执行（`$SHELL -c <command>`），
 *   stdout/stderr 写入输出文件，数量不限，缺省名自动编号（task-1、task-2…）。
 * - task_start 为 fire-and-forget：watcher 等待进程退出后以 steer 消息
 *   回流输出尾部、退出码与输出文件路径。
 * - pi 会话结束（session_shutdown）时所有未关闭任务被幂等清理。
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { accessSync, constants, mkdtempSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

import { BackgroundTask } from "./task.ts";
import type { TaskRecord, TaskResult } from "./types.ts";

const TAIL_LINES = 50;
const AUTO_NAME_PREFIX = "task";
const START_TOOL_DESCRIPTION =
  "Run a command as a one-shot background task. " +
  "This is a fire-and-forget tool: the call returns immediately with only an acknowledgement. " +
  "The task runs with the user's login shell, inheriting pi's cwd and environment. " +
  "When the task finishes, the harness AUTOMATICALLY delivers the result as a steer message " +
  "containing the exit code, the task's output, and the full output file path. " +
  "DO NOT write polling loops, sleep/wait commands, tail/watch scripts, or repeatedly call task_read to " +
  "detect completion. All of that is wasted work — the harness handles delivery for you. " +
  "After starting a task, either end your turn immediately, or work on other independent tasks.";

const TaskStartParams = Type.Object({
  command: Type.String({ description: "The command to execute. Required." }),
  name: Type.Optional(
    Type.String({ description: "Task name. Defaults to auto-numbered 'task-N'." }),
  ),
  cwd: Type.Optional(
    Type.String({ description: "Working directory for the task. Defaults to pi's current working directory." }),
  ),
});

const TaskReadParams = Type.Object({
  name: Type.String({ description: "Name of the task." }),
  lines: Type.Optional(
    Type.Number({ description: `Number of trailing output lines to return. Default ${TAIL_LINES}.` }),
  ),
});

const TaskCloseParams = Type.Object({
  name: Type.Optional(
    Type.String({ description: "Name of the task to close. Omit to close all tasks." }),
  ),
});

// ── 系统提示词指导（before_agent_start 注入 tool_guidance 段） ──

const SYSTEM_PROMPT_GUIDANCE = [
  "Background tasks (task_start) run one command without blocking the conversation. " +
    "Use them for long-running commands (builds, tests, batches) and for work whose output " +
    "you need later; use the built-in bash tool for quick foreground commands.",
  "task_start is fire-and-forget: the result arrives automatically as a steer message " +
    "with the exit code, the task's output, and the output file path. " +
    "Do NOT poll for completion.",
  "Use task_read only to inspect progress while a task is still running; never to wait for completion.",
  "Tasks are one-shot: each task runs a single command and cannot be reused. " +
    "Start a new task for each command; tasks are auto-named task-1, task-2…",
  "Tasks are cleaned up when pi exits; call task_close when a task is no longer needed.",
].join("\n");

// ── 会话级注册表（/reload 安全：存放在 globalThis） ──

const REGISTRY_KEY = Symbol.for("pi-background-task/registry");
const ABORT_KEY = Symbol.for("pi-background-task/abort-controller");

interface Registry {
  tasks: Map<string, TaskRecord>;
  /** 本会话的输出目录，session_start 时创建。 */
  outputDir: string | null;
}

/** globalThis 上的槽位访问集中在此，避免 any 绕过类型检查。 */
const globalSlots = globalThis as unknown as { [key: symbol]: unknown };

function globalRegistry(): Registry | undefined {
  return globalSlots[REGISTRY_KEY] as Registry | undefined;
}

function globalAbort(): AbortController | undefined {
  return globalSlots[ABORT_KEY] as AbortController | undefined;
}

let registry: Registry;

let latestPi: ExtensionAPI | null = null;

function errorResult(text: string, error: string) {
  return {
    content: [{ type: "text" as const, text }],
    details: { error },
  };
}

function nextAutoName(): string {
  for (let n = 1; ; n++) {
    const candidate = `${AUTO_NAME_PREFIX}-${n}`;
    if (!registry.tasks.has(candidate)) return candidate;
  }
}

function resolveCwd(cwd: string | undefined): { cwd: string } | { error: string } {
  const target = resolve(cwd ?? process.cwd());
  try {
    if (!statSync(target).isDirectory()) {
      return { error: `cwd is not a directory: ${target}` };
    }
  } catch {
    return { error: `cwd does not exist: ${target}` };
  }
  return { cwd: target };
}

function loginShell(): { shell: string } | { error: string } {
  const shell = process.env.SHELL;
  if (!shell) {
    return { error: "SHELL environment variable is not set; cannot determine the login shell." };
  }
  try {
    accessSync(shell, constants.X_OK);
  } catch {
    return { error: `login shell is not executable: ${shell}` };
  }
  return { shell };
}

/** name 同时用于输出文件名，限制为安全字符集。 */
const NAME_PATTERN = /^[A-Za-z0-9][A-Za-z0-9_-]*$/;

function validateName(name: string): string | null {
  return NAME_PATTERN.test(name) ? null : `invalid task name "${name}": use letters, digits, '-' or '_'`;
}

function tailLines(text: string, lines: number): string {
  const split = text.split("\n");
  if (split.length <= lines) return text;
  return split.slice(-lines).join("\n");
}

function buildSteerContent(record: TaskRecord, result: TaskResult): string {
  const output = result.output ? tailLines(result.output, TAIL_LINES) : "";
  const outcome =
    result.exitCode === 0 && !result.errorMessage
      ? `Task "${record.name}" completed (exit 0).`
      : `Task "${record.name}" failed (exit code ${result.exitCode})${
          result.errorMessage ? ` — ${result.errorMessage}` : ""
        }.`;
  return [outcome, "", output, "", `Full output: ${record.backend.outputFile}`].join("\n");
}

/** fire-and-forget watcher：任务结束后以 steer 消息回流结果。 */
function watchTask(record: TaskRecord, signal: AbortSignal): void {
  const pi = latestPi;
  if (!pi) return;
  record.backend
    .wait(signal)
    .then((result) => {
      record.state = result.exitCode === 0 && !result.errorMessage ? "done" : "failed";
      pi.sendMessage(
        {
          customType: "task_result",
          content: buildSteerContent(record, result),
          display: true,
          details: {
            name: record.name,
            command: record.command,
            exitCode: result.exitCode,
            ...(result.errorMessage ? { errorMessage: result.errorMessage } : {}),
            outputFile: record.backend.outputFile,
          },
        },
        { triggerTurn: true, deliverAs: "steer" },
      );
    })
    .catch((err) => {
      record.state = "failed";
      pi.sendMessage(
        {
          customType: "task_result",
          content: `Task "${record.name}" watcher error: ${err?.message ?? String(err)}`,
          display: true,
          details: { name: record.name, command: record.command, error: err?.message },
        },
        { triggerTurn: true, deliverAs: "steer" },
      );
    });
}

// ── task 摘要展示（task_list 与 /tasks 共用） ──

function taskSummary(record: TaskRecord): string {
  return `${record.name}\t${record.state}\t${record.cwd}\t${record.command}`;
}

function taskDetails(record: TaskRecord) {
  return {
    name: record.name,
    state: record.state,
    cwd: record.cwd,
    command: record.command,
    outputFile: record.backend.outputFile,
  };
}

export default function backgroundTaskExtension(pi: ExtensionAPI) {
  latestPi = pi;

  // /reload 重新加载本文件：旧模块的任务无法被新模块接管，先清理再注册。
  const previous = globalRegistry();
  if (previous) {
    for (const record of previous.tasks.values()) {
      record.backend.close();
    }
  }
  registry = { tasks: new Map(), outputDir: null };
  globalSlots[REGISTRY_KEY] = registry;

  pi.on("before_agent_start", (event) => {
    const existing = event.systemPromptOptions.sections.tool_guidance;
    event.systemPromptOptions.sections.tool_guidance = existing
      ? `${existing}\n${SYSTEM_PROMPT_GUIDANCE}`
      : SYSTEM_PROMPT_GUIDANCE;
  });

  pi.on("session_start", (_event, _ctx) => {
    const prevAbort = globalAbort();
    if (!prevAbort || prevAbort.signal.aborted) {
      globalSlots[ABORT_KEY] = new AbortController();
    }
    if (!registry.outputDir) {
      registry.outputDir = mkdtempSync(join(tmpdir(), "pi-background-task-"));
    }
  });

  pi.on("session_shutdown", (_event, _ctx) => {
    const moduleAbort = globalAbort();
    if (moduleAbort) moduleAbort.abort();
    for (const record of registry.tasks.values()) {
      record.backend.close();
    }
    registry.tasks.clear();
    if (registry.outputDir) {
      rmSync(registry.outputDir, { recursive: true, force: true });
      registry.outputDir = null;
    }
  });

  pi.registerTool({
    name: "task_start",
    label: "Task start",
    description: START_TOOL_DESCRIPTION,
    parameters: TaskStartParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const shell = loginShell();
      if ("error" in shell) {
        return errorResult(`Error: ${shell.error}`, "no login shell");
      }

      const cwd = resolveCwd(params.cwd);
      if ("error" in cwd) {
        return errorResult(`Error: ${cwd.error}`, "invalid cwd");
      }

      let name = params.name?.trim() ?? "";
      if (name) {
        const invalid = validateName(name);
        if (invalid) {
          return errorResult(`Error: ${invalid}.`, "invalid name");
        }
        if (registry.tasks.has(name)) {
          return errorResult(`Error: a task named "${name}" already exists.`, "duplicate name");
        }
      } else {
        name = nextAutoName();
      }

      if (!registry.outputDir) {
        return errorResult(
          "Error: session is not initialized (no output directory).",
          "session not started",
        );
      }

      let record: TaskRecord;
      try {
        const backend = new BackgroundTask(
          shell.shell,
          params.command,
          cwd.cwd,
          join(registry.outputDir, `${name}.log`),
        );
        record = { name, command: params.command, cwd: cwd.cwd, backend, state: "running" };
      } catch (err) {
        return errorResult(
          `Error: failed to start task: ${err?.message ?? String(err)}`,
          "start failed",
        );
      }
      registry.tasks.set(name, record);

      const abort = globalAbort();
      if (!abort || abort.signal.aborted) {
        return errorResult("Error: session is shutting down.", "session not active");
      }
      watchTask(record, abort.signal);

      return {
        content: [
          {
            type: "text" as const,
            text:
              `Task "${name}" started in the background (cwd: ${record.cwd}, shell: ${shell.shell}). ` +
              "The result will be delivered as a steer message when it finishes. Do NOT poll for completion.",
          },
        ],
        details: {
          name,
          command: params.command,
          cwd: record.cwd,
          shell: shell.shell,
          outputFile: record.backend.outputFile,
          status: "running",
        },
      };
    },
  });

  pi.registerTool({
    name: "task_read",
    label: "Task read",
    description:
      "Read the last N lines of a task's output file. " +
      "Use this to inspect progress while a task is still running — " +
      "do NOT use it to wait for completion (the steer message handles that).",
    parameters: TaskReadParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const record = registry.tasks.get(params.name);
      if (!record) {
        return errorResult(`Error: no task named "${params.name}".`, "unknown task");
      }
      const lines = params.lines ?? TAIL_LINES;
      if (!Number.isInteger(lines) || lines <= 0 || lines > 1000) {
        return errorResult(
          `Error: lines must be an integer between 1 and 1000, got ${params.lines}.`,
          "invalid lines",
        );
      }
      let tail: string;
      try {
        tail = record.backend.readTail(lines);
      } catch (err) {
        return errorResult(
          `Error: failed to read task "${record.name}": ${err?.message ?? String(err)}`,
          "read failed",
        );
      }
      return {
        content: [{ type: "text" as const, text: tail || "(no output)" }],
        details: {
          name: record.name,
          state: record.state,
          outputFile: record.backend.outputFile,
        },
      };
    },
  });

  pi.registerTool({
    name: "task_list",
    label: "Task list",
    description: "List all tasks with their name, state, cwd, and command.",
    parameters: Type.Object({}),

    async execute() {
      if (registry.tasks.size === 0) {
        return {
          content: [{ type: "text" as const, text: "No tasks running." }],
          details: { tasks: [] },
        };
      }
      const tasks = [...registry.tasks.values()].map(taskDetails);
      const text = tasks.map(taskSummary).join("\n");
      return {
        content: [{ type: "text" as const, text }],
        details: { tasks },
      };
    },
  });

  pi.registerTool({
    name: "task_close",
    label: "Task close",
    description:
      "Close a task by name (kills the process if still running, keeps the output file) " +
      "and remove it from the registry. Omit the name to close all tasks.",
    parameters: TaskCloseParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const name = params.name?.trim() ?? "";
      if (!name) {
        const count = registry.tasks.size;
        for (const record of registry.tasks.values()) {
          record.backend.close();
        }
        registry.tasks.clear();
        return {
          content: [{ type: "text" as const, text: `Closed ${count} task(s).` }],
          details: { closed: count },
        };
      }
      const record = registry.tasks.get(name);
      if (!record) {
        return errorResult(`Error: no task named "${name}".`, "unknown task");
      }
      record.backend.close();
      registry.tasks.delete(name);
      return {
        content: [{ type: "text" as const, text: `Task "${name}" closed.` }],
        details: { name, closed: true },
      };
    },
  });

  pi.registerCommand("tasks", {
    description: "List background tasks: /tasks",
    handler: async (_args, ctx) => {
      if (registry.tasks.size === 0) {
        ctx.ui.notify("No tasks running.", "info");
        return;
      }
      const lines = [...registry.tasks.values()].map(taskSummary);
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
