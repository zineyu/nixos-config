/**
 * background-task 后端手工 QA 脚本（真实进程，无 mock）。
 *
 * 用法：node qa/backend-checks.mjs
 * 前置：在装有 fish 的机器上运行（验证 fish 与 POSIX 双路径）。
 * 覆盖规格「测试决策」中可由脚本化的后端验收项；工具层验收见 qa/QA.md。
 */
import { mkdtempSync, readFileSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { BackgroundTask } from "../task.ts";
import { stripAnsi } from "../ansi.ts";

const POSIX_SHELL = "/bin/sh";
const results = [];

function check(name, fn) {
  results.push({ name, fn });
}

function assert(cond, message) {
  if (!cond) throw new Error(`assert failed: ${message}`);
}

function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(`assert failed: ${message} (expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)})`);
  }
}

const waitWithTimeout = (promise, ms, label) =>
  Promise.race([promise, new Promise((_, rej) => setTimeout(() => rej(new Error(`${label}: never settled`)), ms))]);

function newTask(shellPath, dir, name, command, cwd = "/tmp") {
  return new BackgroundTask(shellPath, command, cwd, join(dir, `${name}.log`));
}

// ── ANSI 剥离 ──

check("stripAnsi 移除 CSI/OSC/两字符序列与 \\r", () => {
  assertEqual(
    stripAnsi("\x1b[1;32mhello\x1b[0m \x1b[6 q\x1b]7;file://x\x07a\rb"),
    "hello ab",
    "stripAnsi",
  );
});

// ── 一次性任务（POSIX shell 路径） ──

check("sh：任务执行、退出码与输出回流", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(POSIX_SHELL, dir, "sh-basic", "echo qa-output && sleep 1");
  assert(t.isAlive(), "alive after start");
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "sh-basic");
  assertEqual(r.exitCode, 0, "exit code");
  assert(r.output.includes("qa-output"), "output contains result");
  assert(t.readTail(50).includes("qa-output"), "readTail contains output");
  assert(!t.isAlive(), "dead after exit");
});

check("sh：非零退出码（exit 7）", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(POSIX_SHELL, dir, "sh-exit7", "echo before-exit; exit 7");
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "sh-exit7");
  assertEqual(r.exitCode, 7, "exit code 7");
  assert(r.output.includes("before-exit"), "output preserved");
});

check("sh：外部 SIGKILL 显式失败、不挂起", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(POSIX_SHELL, dir, "sh-kill", "sleep 30");
  setTimeout(() => process.kill(-t.pid, "SIGKILL"), 1000);
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "sh-kill");
  assertEqual(r.exitCode, 1, "exit code");
  assert(r.errorMessage?.includes("signal"), "signal error message");
  assert(!t.isAlive(), "isAlive false");
  t.close();
});

check("sh：spawn ENOENT 显式失败、不挂起", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = new BackgroundTask("/nonexistent-shell-xyz", "echo y", "/tmp", join(dir, "enoent.log"));
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "spawn-enoent");
  assertEqual(r.exitCode, 1, "exit code");
  assert(r.errorMessage?.includes("failed to spawn task"), "error message");
  t.close();
});

check("sh：cwd 覆盖生效", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(POSIX_SHELL, dir, "sh-cwd", "pwd", "/");
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "sh-cwd");
  assertEqual(r.exitCode, 0, "exit code");
  assert(r.output.trim().endsWith("/"), "cwd is /");
});

// ── login shell（fish）路径 ──

check("fish：任务执行与退出码", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(process.env.SHELL ?? "/bin/sh", dir, "fish-basic", "echo fish-round && sleep 1");
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "fish-basic");
  assertEqual(r.exitCode, 0, "exit code");
  assert(r.output.includes("fish-round"), "output");
  t.close();
});

check("fish：非零退出码（exit 7）", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(process.env.SHELL ?? "/bin/sh", dir, "fish-exit7", "echo f; exit 7");
  const r = await waitWithTimeout(t.wait(new AbortController().signal), 10000, "fish-exit7");
  assertEqual(r.exitCode, 7, "exit code 7");
});

// ── 输出文件 ──

check("输出文件完整写入，readTail 只读尾部", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const logPath = join(dir, "full.log");
  const t = new BackgroundTask(POSIX_SHELL, "seq 1 100", "/tmp", logPath);
  await waitWithTimeout(t.wait(new AbortController().signal), 10000, "full-output");
  const full = readFileSync(logPath, "utf8");
  assert(full.includes("100"), "full output on disk");
  const tail = t.readTail(3);
  assert(tail.includes("100") && !tail.includes("1\n"), "tail only");
  assert(statSync(logPath).size > 0, "file non-empty");
});

// ── 幂等关闭 ──

check("close 幂等，关闭后可重复调用", async () => {
  const dir = mkdtempSync(join(tmpdir(), "bt-qa-"));
  const t = newTask(POSIX_SHELL, dir, "sh-close", "sleep 30");
  t.close();
  t.close();
  assert(!t.isAlive(), "dead after close");
});

// ── 执行 ──

let failed = 0;
for (const { name, fn } of results) {
  try {
    await fn();
    console.log(`PASS  ${name}`);
  } catch (err) {
    failed += 1;
    console.log(`FAIL  ${name}\n      ${err?.message ?? String(err)}`);
  }
}
console.log(`\n${results.length - failed}/${results.length} checks passed`);
process.exit(failed === 0 ? 0 : 1);
