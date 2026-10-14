---
description: 评审：处理他人评审意见与检查失败，复验之后重新请求评审
argument-hint: "[PR 编号或者 URL]"
---

## 读取意见

用户通过参数提供编号或者 URL 时读取 `$1`；否则从当前对话确定，或者按 sub issue 上的 PR 注释查找；仍无法确定时询问用户。

1. 读取 PR 状态：`gh pr view <编号> --json state,isDraft,reviewDecision,mergeStateStatus,statusCheckRollup,headRefName,closingIssuesReferences,reviews,url`。
2. 读取检查结果：`gh pr checks <编号>`。
3. 读取未解决的意见：用 `gh api graphql` 查询评审线程的 `isResolved` 与 `isOutdated`。REST 不返回线程的解决状态。
4. 用 `gh issue view` 读取 sub issue 与主 issue：主 issue 的正文是规格，sub issue 的验收标准是本次的实施范围。

## 处理

- 检查失败：先修复，使检查通过。检查未通过之前禁止请求人工评审。
- 意见超出 sub issue 的范围、或者与规格冲突：禁止直接修改代码。先与用户更新主 issue 或者新开 sub issue，再继续。
- 其余意见：逐条处理。每一条未解决的 thread 必须给出一个结果，改动（引用提交）或者驳回（给出理由）。禁止解决他人的 thread，禁止静默跳过。

## 复验

加载 code-review skill 并遵循其方法，按 `/start-work` 的规则并行派遣两个 verifier。固定点仍是实施开始时的提交，比较命令保持不变，验证范围覆盖到当前工作区。评审引入的实现改动必须重新通过两个方向之后才能推送。只回复意见、不修改代码时跳过复验。

## 推送与重新请求评审

1. 推送改动。改写已经评审过的分支历史时，必须重新请求评审。
2. PR 仍是 draft 时执行 `gh pr ready <编号>`。
3. 用 `gh pr edit <编号> --add-reviewer <login>` 重新请求评审，并在对应的 thread 上回复结论。

## 报告

报告每一条 thread 的处理结果、两个方向的复验结论、检查状态，以及仍然阻塞合并的事项。

本流程禁止合并 PR（`gh pr merge`，包含 `--auto`），禁止关闭 PR。
