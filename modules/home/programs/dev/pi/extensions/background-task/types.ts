/**
 * background-task 扩展的共享类型。index.ts 只依赖 TaskBackend 接口。
 */

/** running：任务进行中；done：退出码 0；failed：退出码非零、spawn 失败或被信号杀死。 */
export type TaskState = "running" | "done" | "failed";

export interface TaskResult {
  exitCode: number;
  /** spawn 失败、被信号杀死等异常情况的错误说明。 */
  errorMessage?: string;
  /** 任务自身的完整输出（ANSI 已剥离）。 */
  output: string;
}

export interface TaskBackend {
  readonly outputFile: string;
  readonly command: string;
  /** 任务进程是否仍在运行。 */
  isAlive(): boolean;
  /** 读取输出文件的尾部 N 行（运行期进度查看用）。 */
  readTail(lines: number): string;
  /** 等待任务结束并返回结果。 */
  wait(signal: AbortSignal): Promise<TaskResult>;
  /** 终止任务进程。幂等。 */
  close(): void;
}

export interface TaskRecord {
  name: string;
  command: string;
  cwd: string;
  backend: TaskBackend;
  state: TaskState;
}
