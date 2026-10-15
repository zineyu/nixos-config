/**
 * background task 后端 — 一次性 detached 子进程 + 输出文件。
 *
 * 每个任务以 login shell 一次性执行：`$SHELL -c <command>`。
 * 进程退出码即命令退出码，stdout/stderr 追加写入输出文件。
 * 任务不阻塞对话；watcher 等待进程退出后以 steer 消息回流结果。
 */
import { spawn, type ChildProcess } from "node:child_process";
import { closeSync, openSync, readSync, statSync } from "node:fs";

import { stripAnsi } from "./ansi.ts";
import type { TaskBackend, TaskResult } from "./types.ts";

/** 按字节偏移读取文件 [offset, end) 区间。 */
function readRange(filePath: string, offset: number): string {
  const size = statSync(filePath).size;
  if (size <= offset) return "";
  const buffer = Buffer.alloc(size - offset);
  const fd = openSync(filePath, "r");
  try {
    readSync(fd, buffer, 0, buffer.length, offset);
  } finally {
    closeSync(fd);
  }
  return buffer.toString("utf8");
}

export class BackgroundTask implements TaskBackend {
  readonly outputFile: string;
  readonly command: string;
  /** detached 子进程自成进程组，调用方按 -pid 终止整个组。 */
  readonly pid: number | undefined;
  private readonly child: ChildProcess;
  /** 常驻 exit 监听，避免事件先于等待挂载而丢失（信号杀死时 exitCode 为 null）。 */
  private exitObserved: { code: number | null; signal: NodeJS.Signals | null } | null = null;
  private spawnError: Error | null = null;
  private settled = false;
  private exitWaiters: Array<(r: TaskResult) => void> = [];
  private closed = false;

  constructor(shellPath: string, command: string, cwd: string, outputFile: string) {
    this.outputFile = outputFile;
    this.command = command;

    const fd = openSync(outputFile, "a");
    let child: ChildProcess | undefined;
    try {
      child = spawn(shellPath, ["-c", command], {
        cwd,
        detached: true,
        stdio: ["ignore", fd, fd],
      });
    } catch (err) {
      closeSync(fd);
      throw err;
    } finally {
      if (child) closeSync(fd);
    }
    this.child = child;
    this.pid = child.pid;

    this.child.on("error", (err) => {
      this.spawnError = err;
      this.settle();
    });
    this.child.on("exit", (code, signal) => {
      this.exitObserved = { code, signal };
      this.settle();
    });
  }

  isAlive(): boolean {
    return this.spawnError === null && this.exitObserved === null && !this.closed;
  }

  readTail(lines: number): string {
    const size = statSync(this.outputFile).size;
    const readSize = Math.min(size, lines * 256);
    const text = readRange(this.outputFile, size - readSize);
    const parts = text.split("\n");
    // 文件过大只读尾部区间时，首行可能不完整，直接丢弃。
    if (readSize < size && parts.length > 1) parts.shift();
    return stripAnsi(parts.slice(-lines).join("\n"));
  }

  wait(signal: AbortSignal): Promise<TaskResult> {
    return new Promise<TaskResult>((resolve, reject) => {
      if (this.settled && this.exitObserved) {
        resolve(this.buildResult());
        return;
      }
      const onAbort = () => {
        this.exitWaiters = this.exitWaiters.filter((w) => w !== onExit);
        reject(new Error("Aborted while waiting for task to finish"));
      };
      const onExit = (result: TaskResult) => {
        signal.removeEventListener("abort", onAbort);
        resolve(result);
      };
      this.exitWaiters.push(onExit);
      signal.addEventListener("abort", onAbort, { once: true });
    });
  }

  close(): void {
    if (this.closed) return;
    this.closed = true;
    const pid = this.child.pid;
    if (pid != null && !this.exitObserved) {
      try {
        // detached 子进程自成进程组，按组终止以覆盖其派生的子孙进程。
        process.kill(-pid, "SIGKILL");
      } catch {
        // 幂等清理：进程可能已被 session_shutdown 或信号处理终止（ESRCH）。
      }
    }
  }

  private settle(): void {
    if (this.settled) return;
    this.settled = true;
    const result = this.buildResult();
    const waiters = this.exitWaiters;
    this.exitWaiters = [];
    for (const waiter of waiters) waiter(result);
  }

  private buildResult(): TaskResult {
    const output = stripAnsi(readRange(this.outputFile, 0)).trimEnd();
    if (this.spawnError) {
      return { exitCode: 1, errorMessage: `failed to spawn task: ${this.spawnError.message}`, output };
    }
    // 信号杀死时 code 为 null，按失败处理并给出明确说明。
    if (this.exitObserved?.code == null) {
      return {
        exitCode: 1,
        errorMessage: `task terminated by signal ${this.exitObserved?.signal ?? "unknown"}`,
        output,
      };
    }
    return { exitCode: this.exitObserved.code, output };
  }
}
