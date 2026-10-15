# background-task 手工 QA

规格「测试决策」的验收清单与执行记录。后端可脚本化部分见 `backend-checks.mjs`（真实进程，无 mock），运行：`node qa/backend-checks.mjs`。

## 脚本化后端检查（2026-10-15 执行，10/10 通过）

- ANSI 剥离（CSI/OSC/两字符序列与 `\r`）
- sh：任务执行、退出码与输出回流
- sh：非零退出码（exit 7）
- sh：外部 SIGKILL 显式失败、不挂起
- sh：spawn ENOENT 显式失败、不挂起
- sh：cwd 覆盖生效
- fish：任务执行与退出码
- fish：非零退出码（exit 7）
- 输出文件完整写入，readTail 只读尾部
- close 幂等，关闭后可重复调用

## 工具层手工步骤

运行 `pi`（无需 zellij），逐个场景核对（提示词模板中的 `<EXT>` 为本扩展目录）：

1. **全链路**：`pi -p -ne -e <EXT>` 后让模型依次执行 task_start（自动命名与命名各一）、task_read、task_list、task_close，核对语义与输出。
2. **回流**：task_start 长命令（如 `sleep 3` 包裹的命令），确认 steer 消息含退出码、任务输出（尾部 50 行）、输出文件路径，且文件完整。
3. **失败路径**：task_start 执行 `exit 7`，确认 steer 明确标示失败与退出码。
4. **清理**：pi 退出后无残留进程、临时目录已清理；重复触发无副作用；task_close 幂等。
5. **命名**：自动编号（task-1、task-2…）；重名报错；非法 name（如 `../../evil`）被拒。
6. **环境**：任务以 login shell（fish）执行；cwd 默认继承 pi 会话、`cwd` 参数覆盖生效。

## 工具层执行记录（2026-10-15）

以上场景均已实际执行通过（双任务并发、steer 回流、失败路径、list/read/close 全链路、命名规则、cwd 覆盖、login shell 环境继承）。
