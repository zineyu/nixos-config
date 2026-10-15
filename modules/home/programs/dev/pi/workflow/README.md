# zine-pi-workflow

规格驱动的软件开发工作流插件（pi package）：prompt 模板、skill、subagents 扩展三合一。

## 组成

- `prompts/` — 七段工作流命令：
  `/spec`（grilling 追问 + 术语表/ADR + seam 清单）→ `/split`（垂直切片 + 阻塞图）→ `/start-work`（红-绿实施 + 双方向独立验证）→ `/wrap-up`（文档同步 + 验收 + PR）→ `/pr-review`（意见处理 + 复验）→ `/close-out`（合并后同步 + 移交）→ `/retro`（知识沉淀 + 环境复盘）
- `skills/` — prompt 路由到的纪律性 skill：`grilling`、`to-tickets`、`code-review`、`diagnosing-bugs`、`tdd`、`retro`（fork 自 mattpocock/skills，去除 setup 依赖并本地化）
- `extensions/subagents/` — subagent 编排扩展（scout / researcher / worker / verifier 委派模型）

## 安装

本仓库内由 `modules/home/programs/dev/pi/default.nix` 通过符号链接安装：
prompts 与 extensions 链入 `~/.pi/agent/`，skills 链入 `~/.agents/skills/`（pi 原生支持该位置，且与其他 agent 共享）。

作为独立 pi package 使用：`pi install <本目录路径>`。
