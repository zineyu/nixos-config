---
description: 拆分规格：把规格发布为主 issue，并按垂直切片拆出 sub issue
argument-hint: "<规格文档路径>"
---

把规格「$1」发布为主 issue，并拆分为 sub issue。本流程禁止编写实现代码。

## 发布主 issue

读取规格文档：用户通过参数提供路径时读取 `$1`；否则在 `docs/specs/` 下查找本次工作对应的规格，或者从当前对话确定。用 `gh issue create` 创建主 issue，标题使用规格主题，正文使用规格文档的完整内容。创建成功后把主 issue 编号回写到规格文档头部，格式为 `> 主 issue: #<编号>`。

## 垂直拆分

加载 to-tickets skill 并遵循其方法，其中关于 tracker 配置的询问跳过：tracker 是 GitHub，通过 `gh` CLI 操作。切片必须满足：

- 贯穿全部层次，是垂直切片，不是某一层的水平切片。
- 可以独立演示或者验证。
- 可以放进一个全新的上下文窗口完成。
- 验收标准落到规格「测试决策」声明的 seam 上；拆分方案中注明每个切片覆盖的 seam。

需要的 prefactor 排在前面。阻塞关系用 GitHub 原生关系表达，不用正文描述。

## 确认拆分

把拆分方案作为编号列表呈给用户，每条包含标题、阻塞它的切片、交付的行为。询问用户：粒度是否合适；阻塞关系是否正确；是否需要合并或者继续拆分。迭代到用户确认之后再发布。

## 发布 sub issue

按依赖顺序发布，先发布被依赖的切片，使阻塞关系可以引用真实编号。每条使用 `gh issue create --parent <主 issue 编号> --blocked-by <编号列表>`；正文使用 to-tickets skill 的 `<issue-template>` 中的 Parent、What to build、Acceptance criteria 三段，使用原生阻塞边时不写 Blocked by 段。标签使用 `ready-for-agent`，仓库中没有该标签时用 `gh label create` 先创建。

禁止关闭或者修改主 issue。完成后报告主 issue 与全部 sub issue 的编号与标题。
