---
description: 把一台主机交付到生产或构建出测试版本：先验证，只在明确批准后激活
argument-hint: "<主机> [check]"
---

调用 `shipping-and-launch` 技能。

它提供上线前的检查清单、推进顺序、观测顺序与回滚步骤。本命令提供两种模式、配方与唯一的闸门。

## 路由

| 情况 | 技能 |
|---|---|
| 正在部署，或询问上线之前必须准备好什么 | `shipping-and-launch` |
| 部署之后的行为必须事后可见 | `observability-and-instrumentation` |
| 改动已就绪，需要一份 pull request 的描述 | `pr` |

## 模式

- `/ship <主机> check` 构建并验证，不改动任何机器。这是测试路径。
- `/ship <主机>` 执行激活。那是生产，没有回滚就无法撤销。

`$1` 必须出现在 `hosts/default.nix` 中。不要臆造环境名：带 `deploy.enable` 的主机通过网络到达，其余主机就地切换。

## 配方

| 步骤 | 命令 |
|---|---|
| 验证 | `just check` |
| 构建 | `just build <主机>`，或 `just build-darwin <主机>` |
| 远程部署 | `just deploy <主机>`，链路慢时先运行 `just push-cachix <主机>` |
| 就地切换 | `just switch <主机>`，或 `just switch-darwin <主机>` |

## 闸门

激活之前，说出主机、模式，以及被替换的那一代，并记录该代号。等待明确无歧义的肯定回答；含糊的回答不算批准。`check` 不需要闸门。
