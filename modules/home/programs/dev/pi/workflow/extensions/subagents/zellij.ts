/**
 * zellij surface layer — 本扩展唯一支持的终端多路复用器。
 *
 * 扩展对 pane 的所有操作都经过本文件的小型 API：创建 pane、向其输入命令、
 * 读取屏幕、关闭 pane、轮询退出。将 zellij 调用隔离在本文件中，
 * index.ts 因此可以在没有多路复用器的环境下测试。
 *
 * pane 以 `pane:<id>` 形式的 surface 标识（zellij pane id 为数字）。
 * 新 pane 的创建跟随父 pi 所在的 pane（`$ZELLIJ_PANE_ID`），而不是用户的焦点。
 *
 * zellij 实现参照上游 HazAT/pi-interactive-subagents 的 cmux.ts 移植，
 * 依赖 zellij 0.44+ 的 `zellij action --pane-id` 定向操作。
 */
import { execFile, execFileSync } from "node:child_process";
import { promisify } from "node:util";
import {
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

const execFileAsync = promisify(execFile);

// ── 可用性检测 ──

const commandAvailability = new Map<string, boolean>();

function hasCommand(command: string): boolean {
  if (commandAvailability.has(command)) {
    return commandAvailability.get(command)!;
  }

  let available = false;
  try {
    execFileSync("sh", ["-c", `command -v ${command}`], { stdio: "ignore" });
    available = true;
  } catch {
    available = false;
  }

  commandAvailability.set(command, available);
  return available;
}

/**
 * 当运行在 zellij 内且 zellij 二进制在 PATH 上时为 true。
 * zellij 会在其派生的每个进程中设置 `ZELLIJ` 与 `ZELLIJ_SESSION_NAME`。
 */
export function isZellijAvailable(): boolean {
  return !!(process.env.ZELLIJ || process.env.ZELLIJ_SESSION_NAME) && hasCommand("zellij");
}

export function isMuxAvailable(): boolean {
  return isZellijAvailable();
}

export function muxSetupHint(): string {
  return "Start pi inside zellij (`zellij --session pi`, then run `pi`).";
}

function requireZellij(): void {
  if (!isZellijAvailable()) {
    throw new Error(`zellij is required for subagents. ${muxSetupHint()}`);
  }
}

// ── Shell 辅助 ──

export function shellEscape(s: string): string {
  return "'" + s.replace(/'/g, "'\\''") + "'";
}

function tailLines(text: string, lines: number): string {
  const split = text.split("\n");
  if (split.length <= lines) return text;
  return split.slice(-lines).join("\n");
}

function sleepSync(milliseconds: number): void {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds);
}

// ── zellij action 封装 ──

function zellijPaneId(surface: string): string {
  return surface.startsWith("pane:") ? surface.slice("pane:".length) : surface;
}

function zellijEnv(surface?: string): NodeJS.ProcessEnv {
  const env: NodeJS.ProcessEnv = { ...process.env };
  if (surface) {
    env.ZELLIJ_PANE_ID = zellijPaneId(surface);
  }
  return env;
}

/**
 * 必须通过 --pane-id 定向到指定 pane 的 zellij action
 * （多数 action 会忽略 ZELLIJ_PANE_ID 环境变量）。
 * 见 https://github.com/HazAT/pi-interactive-subagents/issues/19
 */
const ZELLIJ_PANE_SCOPED_ACTIONS = new Set([
  "close-pane",
  "dump-screen",
  "rename-pane",
  "move-pane",
  "write",
  "write-chars",
  "send-keys",
]);

function zellijActionArgs(args: string[], surface?: string): string[] {
  if (!surface) return ["action", ...args];
  const action = args[0];
  if (!ZELLIJ_PANE_SCOPED_ACTIONS.has(action)) return ["action", ...args];
  // 调用方已显式指定 --pane-id 时不再重复添加。
  if (args.includes("--pane-id") || args.includes("-p")) return ["action", ...args];
  return ["action", action, "--pane-id", zellijPaneId(surface), ...args.slice(1)];
}

function zellijActionSync(args: string[], surface?: string): string {
  return execFileSync("zellij", zellijActionArgs(args, surface), {
    encoding: "utf8",
    env: zellijEnv(surface),
  });
}

// ── pane 放置策略 ──

// 与 zellij 0.44+ 的内部最小尺寸一致，用于预测无方向 split 时 zellij 自己的选择。
const ZELLIJ_MIN_TERMINAL_WIDTH = 5;
const ZELLIJ_MIN_TERMINAL_HEIGHT = 5;
const ZELLIJ_CURSOR_HEIGHT_WIDTH_RATIO = 4;

// pi subagent 需要比 zellij 内部最小值更多的可用空间，
// 可通过环境变量按会话调整。
const DEFAULT_ZELLIJ_SUBAGENT_MIN_COLUMNS = 50;
const DEFAULT_ZELLIJ_SUBAGENT_MIN_ROWS = 10;

interface ZellijPaneSnapshot {
  id: number;
  is_plugin?: boolean;
  is_floating?: boolean;
  is_selectable?: boolean;
  exited?: boolean;
  pane_rows?: number;
  pane_columns?: number;
  tab_id?: number;
  is_focused?: boolean;
}

type ZellijSplitDirection = "down" | "right";

type ZellijPlacementPlan =
  | {
      mode: "split";
      targetPaneId: number;
      tabId: number;
    }
  | { mode: "stack"; targetPaneId: number; tabId: number };

function paneArea(pane: ZellijPaneSnapshot): number {
  return (pane.pane_rows ?? 0) * (pane.pane_columns ?? 0);
}

function isUsableZellijTiledPane(pane: ZellijPaneSnapshot): boolean {
  return (
    !pane.is_plugin &&
    !pane.is_floating &&
    pane.is_selectable !== false &&
    !pane.exited &&
    typeof pane.pane_rows === "number" &&
    typeof pane.pane_columns === "number"
  );
}

function predictZellijSplitDirection(pane: ZellijPaneSnapshot): ZellijSplitDirection | null {
  const columns = pane.pane_columns ?? 0;
  const rows = pane.pane_rows ?? 0;
  if (columns < ZELLIJ_MIN_TERMINAL_WIDTH || rows < ZELLIJ_MIN_TERMINAL_HEIGHT) return null;

  if (
    rows * ZELLIJ_CURSOR_HEIGHT_WIDTH_RATIO > columns &&
    rows > ZELLIJ_MIN_TERMINAL_HEIGHT * 2
  ) {
    return "down";
  }

  if (columns > ZELLIJ_MIN_TERMINAL_WIDTH * 2) {
    return "right";
  }

  return null;
}

function canSplitZellijPane(
  pane: ZellijPaneSnapshot,
  minColumns = ZELLIJ_MIN_TERMINAL_WIDTH,
  minRows = ZELLIJ_MIN_TERMINAL_HEIGHT,
): boolean {
  const columns = pane.pane_columns ?? 0;
  const rows = pane.pane_rows ?? 0;
  const direction = predictZellijSplitDirection(pane);
  if (!direction) return false;

  if (direction === "down") {
    return columns >= minColumns && Math.floor(rows / 2) >= minRows;
  }

  return rows >= minRows && Math.floor(columns / 2) >= minColumns;
}

function zellijTabPanesForParent(
  panes: ZellijPaneSnapshot[],
  parentPaneId: number,
): { parentPane: ZellijPaneSnapshot; tabPanes: ZellijPaneSnapshot[] } | null {
  const parentPane = panes.find((pane) => !pane.is_plugin && pane.id === parentPaneId);
  if (!parentPane || typeof parentPane.tab_id !== "number") return null;

  const tabPanes = panes
    .filter((pane) => pane.tab_id === parentPane.tab_id)
    .filter(isUsableZellijTiledPane);

  return { parentPane, tabPanes };
}

function selectZellijStackPlacement(
  panes: ZellijPaneSnapshot[],
  parentPaneId: number,
): ZellijPlacementPlan | null {
  const tabInfo = zellijTabPanesForParent(panes, parentPaneId);
  if (!tabInfo) return null;

  const stackTarget = tabInfo.tabPanes
    .filter((pane) => pane.id !== parentPaneId)
    .sort((a, b) => paneArea(b) - paneArea(a))[0];
  if (!stackTarget) return null;

  return {
    mode: "stack",
    targetPaneId: stackTarget.id,
    tabId: tabInfo.parentPane.tab_id!,
  };
}

/**
 * 为新的 subagent pane 选择放置方式：tab 内空间足够时 split，
 * 空间不足时退化为 stacked pane，两者都不可行时开新 tab。
 * split 的具体目标 pane 由 zellij 按 tab 范围自行选择，
 * 因此只有当 zellij 可能选中的每个 pane 在 split 后都仍然可用时才 split。
 */
function selectZellijPlacement(
  panes: ZellijPaneSnapshot[],
  parentPaneId: number,
  minColumns = DEFAULT_ZELLIJ_SUBAGENT_MIN_COLUMNS,
  minRows = DEFAULT_ZELLIJ_SUBAGENT_MIN_ROWS,
): ZellijPlacementPlan | null {
  const tabInfo = zellijTabPanesForParent(panes, parentPaneId);
  if (!tabInfo) return null;

  const splitCandidates = tabInfo.tabPanes.filter(
    (pane) =>
      predictZellijSplitDirection(pane) !== null &&
      canSplitZellijPane(pane, ZELLIJ_MIN_TERMINAL_WIDTH, ZELLIJ_MIN_TERMINAL_HEIGHT),
  );
  const safeSplitCandidates = splitCandidates.filter((pane) =>
    canSplitZellijPane(pane, minColumns, minRows),
  );

  if (splitCandidates.length > 0 && safeSplitCandidates.length === splitCandidates.length) {
    const splitTarget = safeSplitCandidates.sort((a, b) => paneArea(b) - paneArea(a))[0];
    return {
      mode: "split",
      targetPaneId: splitTarget.id,
      tabId: tabInfo.parentPane.tab_id!,
    };
  }

  return selectZellijStackPlacement(panes, parentPaneId);
}

// ── pane 创建 ──

function parseZellijPaneSurface(rawId: string, context: string): string {
  const idMatch = rawId.match(/(\d+)/);
  if (!idMatch) {
    throw new Error(`Unexpected zellij pane id from ${context}: ${rawId || "(empty)"}`);
  }
  return `pane:${idMatch[1]}`;
}

function readZellijPanes(): ZellijPaneSnapshot[] {
  let lastError: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const output = zellijActionSync(["list-panes", "--json", "--geometry", "--state", "--tab"]);
      if (!output.trim()) {
        throw new Error("Unexpected zellij list-panes output: empty");
      }
      const parsed = JSON.parse(output);
      if (!Array.isArray(parsed)) {
        throw new Error("Unexpected zellij list-panes output: not an array");
      }
      return parsed as ZellijPaneSnapshot[];
    } catch (error) {
      lastError = error;
      if (attempt < 2) sleepSync(50);
    }
  }
  throw lastError;
}

function createZellijTiledPane(name: string, tabId: number): string {
  const args = ["new-pane", "--tab-id", String(tabId), "--name", name, "--cwd", process.cwd()];
  return parseZellijPaneSurface(zellijActionSync(args).trim(), "new-pane");
}

function createZellijStackedPane(name: string, anchorSurface: string): string {
  const args = [
    "new-pane",
    "--stacked",
    "--near-current-pane",
    "--name",
    name,
    "--cwd",
    process.cwd(),
  ];
  return parseZellijPaneSurface(zellijActionSync(args, anchorSurface).trim(), "new-pane --stacked");
}

function createZellijTab(name: string): string {
  const tabIdRaw = zellijActionSync(["new-tab", "--name", name, "--cwd", process.cwd()]).trim();
  const tabId = Number(tabIdRaw);
  if (!Number.isInteger(tabId)) {
    throw new Error(`Unexpected zellij tab id from new-tab: ${tabIdRaw || "(empty)"}`);
  }

  try {
    const panes = readZellijPanes();
    const pane = panes.find(
      (candidate) =>
        candidate.tab_id === tabId &&
        isUsableZellijTiledPane(candidate) &&
        typeof candidate.id === "number",
    );
    if (!pane) {
      throw new Error(`Could not find initial pane for zellij tab ${tabId}`);
    }

    const surface = `pane:${pane.id}`;
    try {
      zellijActionSync(["rename-pane", name], surface);
    } catch {
      // 重命名失败不影响使用。
    }
    return surface;
  } catch (error) {
    try {
      zellijActionSync(["close-tab", "--tab-id", String(tabId)]);
    } catch {
      // 创建后检查失败时尽力清理已创建的 tab。
    }
    throw error;
  }
}

function envPositiveInteger(name: string, fallback: number): number {
  const value = Number(process.env[name]);
  return Number.isInteger(value) && value > 0 ? value : fallback;
}

/**
 * zellij 的 pane 创建是 tab 范围的且会移动焦点，并发 spawn 时需要串行化，
 * 否则并发创建会基于过期的 pane 快照互相干扰。
 */
function zellijSurfaceLockPath(): string {
  const session = (process.env.ZELLIJ_SESSION_NAME ?? process.env.ZELLIJ ?? "default").replace(
    /[^A-Za-z0-9_.-]/g,
    "_",
  );
  return join(tmpdir(), `pi-zellij-surface-${session}.lock`);
}

function withZellijSurfaceLock<T>(callback: () => T): T {
  const lockPath = zellijSurfaceLockPath();
  const deadline = Date.now() + 10000;

  while (true) {
    try {
      mkdirSync(lockPath);
      writeFileSync(join(lockPath, "owner"), `${process.pid}\n`);
      break;
    } catch (error) {
      const code = (error as NodeJS.ErrnoException).code;
      if (code !== "EEXIST") throw error;

      try {
        if (Date.now() - statSync(lockPath).mtimeMs > 30000) {
          rmSync(lockPath, { recursive: true, force: true });
          continue;
        }
      } catch {}

      if (Date.now() > deadline) {
        throw new Error(`Timed out waiting for zellij surface lock: ${lockPath}`);
      }
      sleepSync(50);
    }
  }

  try {
    return callback();
  } finally {
    rmSync(lockPath, { recursive: true, force: true });
  }
}

// ── Surface 原语 ──

/**
 * 为 subagent 创建新 pane：优先在父 pi 所在 tab 内 split，
 * 空间不足时退化为 stacked pane 或新 tab。
 * 返回 `pane:<id>` 形式的 surface 标识。
 */
export function createSurface(name: string): string {
  requireZellij();
  return withZellijSurfaceLock(() => {
    const parentPaneIdRaw = process.env.ZELLIJ_PANE_ID;
    const parentPaneId = parentPaneIdRaw ? Number(parentPaneIdRaw) : NaN;
    const minColumns = envPositiveInteger(
      "PI_SUBAGENT_ZELLIJ_MIN_COLUMNS",
      DEFAULT_ZELLIJ_SUBAGENT_MIN_COLUMNS,
    );
    const minRows = envPositiveInteger(
      "PI_SUBAGENT_ZELLIJ_MIN_ROWS",
      DEFAULT_ZELLIJ_SUBAGENT_MIN_ROWS,
    );

    const plan = Number.isInteger(parentPaneId)
      ? selectZellijPlacement(readZellijPanes(), parentPaneId, minColumns, minRows)
      : null;

    if (plan?.mode === "split") {
      return createZellijTiledPane(name, plan.tabId);
    }

    if (plan?.mode === "stack") {
      return createZellijStackedPane(name, `pane:${plan.targetPaneId}`);
    }

    return createZellijTab(name);
  });
}

/**
 * 向 pane 发送命令字符串并执行。
 * 通过 write-chars 原样写入，特殊字符不会被解释为按键，随后写入回车。
 */
export function sendCommand(surface: string, command: string): void {
  requireZellij();
  zellijActionSync(["write-chars", command], surface);
  zellijActionSync(["write", "13"], surface);
}

/**
 * 长命令先写入脚本文件再发送，避免逐字符发送时终端折行
 * 破坏超过 pane 列宽的命令。
 *
 * 默认写入临时目录，调用方可以传入稳定路径（例如 session artifacts 目录下），
 * 以便保留完整调用记录用于调试。
 *
 * 返回脚本路径。
 */
export function sendLongCommand(
  surface: string,
  command: string,
  options?: { scriptPath?: string; scriptPreamble?: string },
): string {
  const scriptPath =
    options?.scriptPath ??
    join(
      tmpdir(),
      "pi-subagent-scripts",
      `cmd-${Date.now()}-${Math.random().toString(16).slice(2, 8)}.sh`,
    );
  mkdirSync(dirname(scriptPath), { recursive: true });

  const scriptParts = ["#!/bin/bash"];
  if (options?.scriptPreamble) {
    scriptParts.push(options.scriptPreamble.trimEnd());
  }
  scriptParts.push(command);

  writeFileSync(scriptPath, scriptParts.join("\n") + "\n", {
    mode: 0o755,
  });
  sendCommand(surface, `bash ${shellEscape(scriptPath)}`);
  return scriptPath;
}

/**
 * 读取 pane 的屏幕内容（同步）。
 * zellij 0.44+：使用 --pane-id 定向并直接从 stdout 读取；
 * ZELLIJ_PANE_ID 环境变量对 dump-screen 的定向不可靠。
 */
export function readScreen(surface: string, lines = 50): string {
  requireZellij();
  const raw = zellijActionSync(["dump-screen"], surface);
  return tailLines(raw, lines);
}

/** 读取 pane 的屏幕内容（异步）。 */
export async function readScreenAsync(surface: string, lines = 50): Promise<string> {
  requireZellij();
  const { stdout } = await execFileAsync(
    "zellij",
    zellijActionArgs(["dump-screen"], surface),
    {
      encoding: "utf8",
      env: zellijEnv(surface),
    },
  );
  return tailLines(stdout, lines);
}

/** 关闭 pane。zellij 自动平铺，关闭后无需手动重排布局。 */
export function closeSurface(surface: string): void {
  requireZellij();
  zellijActionSync(["close-pane"], surface);
}

// ── 退出轮询 ──

export interface PollResult {
  /** subagent 的退出方式 */
  reason: "done" | "sentinel" | "error";
  /** Shell 退出码（来自 sentinel）。文件方式退出时为 0。 */
  exitCode: number;
  /** reason 为 "error" 时的错误信息（自动重试耗尽、provider 过载等） */
  errorMessage?: string;
}

/**
 * 解释 `.exit` sidecar 的内容（由 subagent-done.ts 的错误路径写入）。
 * 集中在此处，使 pollForExit 的快慢两条路径以相同方式解码。
 * 正常完成不写 sidecar，通过终端 sentinel 检测。
 *
 * 注意：ask_question 不写 `.exit` sidecar —— 它保持 session 打开，
 * 通过单独的 `.ask` 文件通知父 session（见 deliverPendingQuestion）。
 */
function interpretExitSidecar(data: any): PollResult {
  if (data?.type === "error") {
    const errorMessage =
      typeof data.errorMessage === "string" && data.errorMessage.trim() !== ""
        ? data.errorMessage
        : "Subagent exited with stopReason=error (no errorMessage in sidecar).";
    return { reason: "error", exitCode: 1, errorMessage };
  }
  return { reason: "done", exitCode: 0 };
}

export const __pollForExitTest__ = { interpretExitSidecar };

/**
 * 轮询直到 subagent 退出。先检查 `.exit` sidecar 文件（错误路径写入），
 * 再通过终端 sentinel 检测正常完成与崩溃。
 */
export async function pollForExit(
  surface: string,
  signal: AbortSignal,
  options: {
    interval: number;
    sessionFile?: string;
    sentinelFile?: string;
    onTick?: (elapsed: number) => void;
  },
): Promise<PollResult> {
  const start = Date.now();

  for (;;) {
    if (signal.aborted) {
      throw new Error("Aborted while waiting for subagent to finish");
    }

    // 快速路径：检查 .exit sidecar 文件（错误路径写入）
    if (options.sessionFile) {
      try {
        const exitFile = `${options.sessionFile}.exit`;
        if (existsSync(exitFile)) {
          const data = JSON.parse(readFileSync(exitFile, "utf-8"));
          rmSync(exitFile, { force: true });
          return interpretExitSidecar(data);
        }
      } catch {}
    }

    // 检查 Claude sentinel 文件（由 plugin Stop hook 写入）
    if (options.sentinelFile) {
      try {
        if (existsSync(options.sentinelFile)) {
          return { reason: "sentinel", exitCode: 0 };
        }
      } catch {}
    }

    // 慢速路径：读取终端屏幕查找 sentinel（崩溃检测）
    try {
      const screen = await readScreenAsync(surface, 5);
      const match = screen.match(/__SUBAGENT_DONE_(\d+)__/);
      if (match) {
        return { reason: "sentinel", exitCode: parseInt(match[1], 10) };
      }
    } catch {
      // Surface 可能已被销毁 —— 检查此期间是否出现了 .exit 文件
      if (options.sessionFile) {
        try {
          const exitFile = `${options.sessionFile}.exit`;
          if (existsSync(exitFile)) {
            const data = JSON.parse(readFileSync(exitFile, "utf-8"));
            rmSync(exitFile, { force: true });
            return interpretExitSidecar(data);
          }
        } catch {}
      }
    }

    const elapsed = Math.floor((Date.now() - start) / 1000);
    options.onTick?.(elapsed);

    await new Promise<void>((resolve, reject) => {
      if (signal.aborted) return reject(new Error("Aborted"));
      const timer = setTimeout(() => {
        signal.removeEventListener("abort", onAbort);
        resolve();
      }, options.interval);
      function onAbort() {
        clearTimeout(timer);
        reject(new Error("Aborted"));
      }
      signal.addEventListener("abort", onAbort, { once: true });
    });
  }
}
