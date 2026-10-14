---
description: 收尾：PR 合并或者关闭之后同步状态，并确定下一片
argument-hint: "[PR 编号或者 URL]"
---

## 读取终态

用户通过参数提供编号或者 URL 时读取 `$1`；否则从当前对话确定，或者按 sub issue 上的 PR 注释查找；仍无法确定时询问用户。

1. 读取 PR 终态：`gh pr view <编号> --json state,mergedAt,mergeCommit,closedAt,headRefName,closingIssuesReferences,url`。
2. 用 `gh issue view` 读取 sub issue 与主 issue。

## PR 已经合并

1. 同步默认分支：拉取远端，把工作副本移到更新后的默认分支。
2. 删除本次的专用分支，包括远端分支与本地分支。
3. 确认 sub issue 已经由 `Closes #<编号>` 关闭。仍然打开时，在 sub issue 上注释改动清单、验证结论与遗留问题，然后关闭。
4. 重算依赖图：读取主 issue 下仍然打开的 sub issue 与它们的阻塞关系，列出阻塞已经全部关闭、可以立即开始的切片。

## PR 未合并即关闭

1. 在 sub issue 上注释 PR 的结论与驳回理由。
2. 禁止自行重新打开或者关闭 sub issue。把该切片的状态与可选处理（重新实施、重新拆分、放弃）报告给用户，由用户决定。

## 报告与移交

报告 PR 终态、sub issue 状态、可以立即开始的切片、需要用户决定的事项。

用 handoff 工具把下一片的编号与规格位置交给新的上下文。全部 sub issue 关闭之后，主 issue 的处理由用户决定。

本流程禁止合并 PR，禁止修改或者关闭主 issue。
