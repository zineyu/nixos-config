# zine-pi-workflow

规格驱动的软件开发工作流插件（pi package）：prompt 模板、skill、subagents 扩展三合一。

## 组成

- `prompts/` — 八段工作流命令（`/brainstorm` 的拆分方法与 `/retro` 的复盘方法已直接内联在 prompt 中；`grilling`、`code-review`、`diagnosing-bugs`、`tdd` 等通用 skill 放在仓库根 `skills/`，由 prompts 路由加载）：
  `/brainstorm`（发散探索 + 方向共识 + 设计草稿）→ `/spec`（grilling 追问 + 术语表/ADR + seam 清单）→ `/split`（垂直切片 + 阻塞图）→ `/start-work`（红-绿实施 + 双方向独立验证）→ `/wrap-up`（文档同步 + 验收 + PR）→ `/pr-review`（意见处理 + 复验）→ `/close-out`（合并后同步 + 移交）→ `/retro`（知识沉淀 + 环境复盘）
- `extensions/subagents/` — subagent 编排扩展（scout / researcher / worker / verifier 委派模型）

## 安装

本仓库内由 `modules/home/programs/dev/pi/default.nix` 通过符号链接安装：
workflow 以 pi package 身份链入 `~/.pi/agent/packages/`，prompts 与 extensions 由包声明加载；prompt 路由到的通用 skill 在仓库根 `skills/` 下，由 `modules/home/agent-skills` 链接到 `~/.agents/skills/`（与其他 agent 共享）。

作为独立 pi package 使用：`pi install <本目录路径>`。
