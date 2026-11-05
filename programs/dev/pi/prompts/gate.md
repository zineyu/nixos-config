---
description: 把本仓库的质量门槛写进 CONSTRAINTS.md，然后守住它不被悄悄放宽
argument-hint: "[check | guard | ratchet]"
---

调用 `constraint-driven-development` 技能。

它提供访谈、`CONSTRAINTS.md` 的各个小节、带默认值的四个问题，以及守卫所观察的五种动作。本命令提供入口，以及每项产出的落点。

## 路由

| 情况 | 技能 |
|---|---|
| 还没有写下的门槛，必须选一个 | `constraint-driven-development` |
| 同一条纠正已经出现两次，必须停止重复 | `correct` |
| 变更接受不可信输入，或触及认证、密钥、依赖 | `security-and-hardening` |
| 变更触及流水线或检查本身 | `ci-cd-and-automation` |

## 落点

- 门槛：仓库根目录的 `CONSTRAINTS.md`
- 指针：`CONTEXT.md` 中的一行，告诉 agent 去读它，并永不为了让变更通过而放宽它
- 命令：每条检查一个 `just` 配方，写在该规则所在表格行的名称里

## 子命令

- `/gate` 运行访谈并写下门槛
- `/gate check` 对当前分支运行每一条规则，每条规则一行，带退出状态
- `/gate guard` 扫描 diff 中的五种动作，并逐个报告 `file:line`
- `/gate ratchet` 测量当前值，并把该值记为不得下降的下限
