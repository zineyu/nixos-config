# pi Background Task Agent 插件规格

## 问题陈述

pi（coding agent harness）内置的 bash 工具只能前台执行命令并阻塞对话；仓库现有的 `subagents` 扩展解决的是“spawn 子 agent”的问题，但不提供轻量的后台任务能力。用户需要：让主 agent 启动一次性后台任务（构建、测试、批处理），不阻塞主对话，任务完成后结果（输出、退出码）自动回流；任务数量不受限制。

## 目标与非目标

### 目标

- 提供一组 pi 自定义工具（`task_start` / `task_read` / `task_list` / `task_close`），主 agent 直接可用。
- 任务以一次性 detached 进程运行（`$SHELL -c <command>`），stdout/stderr 写入输出文件，进程退出即完成，退出码即命令退出码。
- task_start 不阻塞对话；任务完成后通过 steer 消息自动回流任务自身的输出（尾部 50 行）、退出码与输出文件路径。
- 所有未关闭任务在 pi 会话结束时被清理（`session_shutdown`，幂等）。
- 提供一个 `/tasks` 命令列出当前所有任务的状态。

### 非目标

- 不提供持久 shell（无跨命令状态保留、无 REPL）；每个任务一次性执行单条命令，不可复用。
- 不提供可交互 shell（zellij pane），不依赖 zellij；任何环境可直接使用。
- 不定义新的 agent profile（不新增 `.md` agent 定义），不依赖 subagents 扩展。
- 不提供 config.json 配置项，所有默认值硬编码。
- 不提供 TUI 状态 widget。
- 不做任务跨 pi 重启的持久化（resume）。
- 不引入自动化测试设施（仓库现状对 pi 扩展零测试设施；后端提供可重复运行的手工 QA 脚本，见 `qa/`）。

## 用户故事

1. **US-1 启动后台任务**：作为 pi 用户，我可以让主 agent 以 task_start 启动一次性后台任务（如 `nixos-rebuild build`），对话立即继续不阻塞。
2. **US-2 结果自动回流**：任务完成后，我收到一条 steer 消息，包含退出码、任务自身的输出（尾部 50 行）、完整输出文件路径。
3. **US-3 按需查看输出**：任务运行期间，我可以让主 agent `task_read` 查看任意任务输出文件的尾部。
4. **US-4 多个并发任务**：我可以同时运行多个互不干扰的后台任务，数量不限；未命名时自动编号（task-1、task-2…）。
5. **US-5 命名与关闭**：我可以为任务指定 name，并随时让 agent 关闭指定任务或全部任务（运行中任务被终止，输出文件保留至会话结束）。
6. **US-6 状态一览**：我可以通过 `/tasks` 命令或 `task_list` 工具看到所有任务的名称、状态（running/done/failed）、cwd、命令。
7. **US-7 工作环境正确**：每个任务使用我的 login shell（如 fish），继承 pi 会话的 cwd 与环境变量；可按次覆盖 cwd。
8. **US-8 干净退出**：pi 会话结束时，所有未关闭任务的进程被清理，不留孤儿进程。
9. **US-9 明确失败**：退出码非零、命令不存在（spawn 失败）、进程被信号杀死等失败路径以明确错误信息呈现，steer 永不挂起。

## 实现决策

### 总体架构

- 单个 pi extension（TypeScript 目录形式，jiti 免编译），工厂函数内只注册工具/命令，不启动任何进程（遵循上游 extensions.md 生命周期契约）。
- 长驻资源（任务注册表、watcher、detached 进程句柄）在 `session_start` 创建，在 `session_shutdown` 幂等清理。

### 模块划分（逻辑分层，非文件路径）

- **工具层**：4 个单职责工具的注册与参数 schema（TypeBox）。参数校验在工具内完成，非法输入返回明确错误，不使用哨兵值。
- **一次性进程后端**：以 `node:child_process` spawn login shell 一次性执行命令（`$SHELL -c <command>`，`detached` 自成进程组，cwd/env 继承 pi 会话）。stdout/stderr 重定向到输出文件（pi 会话临时目录下）。进程退出码即命令退出码——无需 sentinel、无需 FIFO 驱动循环（两者是持久 shell 模型的产物）。
- **完成通知**：fire-and-forget。task_start 立即返回；常驻 `exit` 监听捕获进程退出（信号杀死时 exitCode 为 null，仅 signalCode，需显式区分），watcher 以 `deliverAs: "steer"` + `triggerTurn: true` 消息回流。工具描述中明确禁止主 agent 轮询。
- **注册表**：会话内存中的 name → 任务记录（名称、命令、cwd、后端句柄、状态机：running/done/failed、输出文件路径）。name 冲突 fast-fail 报错，name 限制为安全字符集（同时用于输出文件名）。任务数量不设上限。
- **`/tasks` 命令**：遍历注册表输出状态列表；无 TUI widget。

### 接口形态

- `task_start`：参数 `command`（必填）、`name`（可选，缺省自动编号 task-N）、`cwd`（可选，默认 pi 会话 cwd）。
- `task_read`：参数 `name`、`lines`（可选，默认 50）。读取输出文件尾部 N 行（运行期进度查看用）。
- `task_list`：无参数，返回全部任务摘要。
- `task_close`：参数 `name`（可选，省略则全部关闭）。终止运行中进程并从注册表移除。

### 架构取舍

- **一次性进程模型**：任务生命周期 = 进程生命周期，完成判定直接依赖进程退出事件，消除了持久 shell 的 REPL 驱动、sentinel 扫描与命令段提取复杂度。
- **detached + 进程组终止**：detached 使子进程自成进程组，清理时按组 SIGKILL 覆盖其派生的子孙进程；pi 自身也会在退出信号时终止其跟踪的 detached 子进程。
- **输出文件保留至会话结束**：task_close 只终止进程并移除注册表项，输出文件留在会话临时目录供事后查阅，随 session_shutdown 统一清理。
- **默认值硬编码**：尾部 50 行、自动编号前缀 `task-` 均为常量。

### 安装

- 扩展目录放入 `modules/home/programs/dev/pi/extensions/`，由既有 `home.file` 机制自动 symlink 到 `~/.pi/agent/extensions/`，Nix 侧零改动。

## 测试决策

仓库对 pi 扩展无自动化测试设施（无 package.json / tsc / vitest，CI 只覆盖 Nix）。后端提供可重复运行的手工 QA 脚本 `qa/backend-checks.mjs`（真实进程，无 mock）；工具层按场景清单人工执行。验收标准：

1. **全链路**：`task_start` / `task_read` / `task_list` / `task_close` 各工具调用成功且语义正确。
2. **回流**：长命令 fire-and-forget 后，主 session 收到 steer 消息，内容含退出码、任务自身输出（尾部 50 行）、输出文件路径，文件内容完整。
3. **失败路径**：`exit 7` 明确标示失败与退出码；外部 SIGKILL、spawn ENOENT 显式失败不挂起。
4. **并发**：多个任务并发互不影响；自动编号、重名报错、非法 name 拒绝。
5. **清理**：pi 正常退出后所有进程终止、临时目录清理；重复触发 `session_shutdown` 无副作用；task_close 幂等。
6. **环境**：任务以 login shell（fish）执行；cwd 默认继承 pi 会话、可覆盖且生效；非 zellij 环境可直接使用。

人工 QA 方式：加载扩展后按场景清单逐项操作并核对结果，记录见 `qa/QA.md`。

## 约束与依赖

- **pi 扩展契约**：工厂内不启动进程/定时器/监听；长驻资源从 `session_start` 管理，`session_shutdown` 幂等清理（上游 extensions.md）。
- **运行环境**：扩展运行在 pi 进程内（Node/Bun 模块），可使用 `node:child_process`；bundled 依赖（`@sinclair/typebox` 等）由 pi 经 jiti 虚拟模块提供，扩展目录内不引入 node_modules / package.json。
- **仓库规范**：注释用中文（专业术语保留英文）、禁止 fallback 与静默失败、禁止 mock（含 QA 过程）。
- **Nix 侧**：无新增 Nix 代码。
- **import 注意**：仓库现有扩展 import 使用 `@mariozechner/*` scope，以本仓库 pin 的 pi 版本实际提供的虚拟模块为准。
