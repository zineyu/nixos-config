/**
 * ANSI 转义序列剥离：shell 输出（screen dump、登录 shell rc 输出）
 * 可能携带颜色与控制序列，进入 agent 上下文前统一移除；\r 一并移除。
 */

// CSI（颜色/光标等）、OSC、以及两字符序列（如 \x1b(B、\x1b=）。
const ANSI_PATTERN =
  /\x1B(?:\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1B\\)|[@-Z\\-_]|\([0-9A-B]|\|[0-9;]*|#[0-9]|[0-9;]*[A-Za-z])/g;

export function stripAnsi(text: string): string {
  return text.replace(ANSI_PATTERN, "").replace(/\r/g, "");
}
