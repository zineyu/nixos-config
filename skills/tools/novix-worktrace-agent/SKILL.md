---
name: novix-worktrace-agent
description: Use when an agent needs to collaborate in NovixWorkTrace on test feedback, requirements, tasks, or evidence submission with the current user's permissions.
---

# NovixWorkTrace Agent Skill

## 范围

这个 skill 只支持测试反馈、需求、任务、凭证提交四类团队协作场景。所有调用都使用当前用户权限，不提供管理员管理、配置、薪资、绩效、同步、通知、员工管理或平台运营能力。

如果用户要求四类场景之外的操作，直接回复：`该 skill 不支持此类操作，请在 NovixWorkTrace 网页或管理功能中处理。`

## 使用流程

1. 运行 `python scripts/novix_api.py capabilities` 查看当前账号、session、可见仓库和权限。
2. 运行 `python scripts/novix_api.py summary --search requirement|task|feedback|evidence` 查找 scoped OpenAPI 中的可用操作。
3. 用 `python scripts/novix_api.py request METHOD PATH` 执行需求、任务、测试反馈或凭证提交相关操作。JSON 请求使用 `--json`，二进制附件上传使用 `--file`，必要时用 `--content-type` 覆盖自动识别的类型。
4. 凭证快过期时，先询问用户；用户同意后运行 `python scripts/novix_api.py renew --days 30`。

Scoped OpenAPI 地址是 `/api/agent-skill/openapi`，其中只包含本 skill 支持的协作接口。

## 业务边界

- 测试反馈：查看、创建、复审、关闭、重新提交和发布到广场。
- 需求：创建、查看、更新、评论、验收、作废，以及和任务建立或移除关联。
- 任务：查看、发布，并按 workflow 返回的动作推进任务；读取评论、评论、关联任务、关联 PR 和查看详情动态。
- 凭证提交：上传附件，提交任务交付凭证，刷新、评论、采纳、排除、恢复凭证。

## 需求与任务

- `Requirement` 是产品/业务需求，创建、更新、评论、验收和作废都走 `/api/requirements...`。
- `TeamTask` 是工程执行任务，统一走 `/api/tasks...`。建任务用 `POST /api/tasks` 且必须带 `workflow` 和 `reviewer_employee_id`（评审人）；`requires_testing=true` 时还必须带 `tester_employee_id`（测试人）。任务动作由 `GET /api/tasks/{id}/actions` 返回，用 `POST /api/tasks/{id}/actions/{action}` 执行。
- 旧版固定动作 URL（`assign`、`claim`、`start`、`complete`、`accept` 等）在存量任务清理完成前仍可用，但只适用于尚未迁移的旧任务。
- 任务和需求的 GitHub Issue 评论线程分别用 `GET /api/tasks/{id}/github-issue-comments` 与 `GET /api/requirements/{id}/github-issue-comments` 读取。
- 关联 PR 时先查看候选或已关联列表，再用 `POST /api/tasks/{id}/pull-requests` 提交 GitHub PR URL、`owner/repo#number`、`#number` 或内部 PR ID。只有同仓库且已合并、关闭的 PR 可以关联。
- Workflow 任务先按附件类型调用 `POST /api/uploads/images` 或 `POST /api/uploads/files`，再调用 `POST /api/workflow-tasks/{id}/evidence` 提交 `url`、`title` 和可选 `notes`。旧任务的凭证评论继续使用 `POST /api/tasks/{id}/evidence-comments`。
- 不要用 `POST /api/tasks` 创建需求，即使 payload 中出现 `task_type=feature`。
- GitHub `Issue` 只是同步承载，不是此 skill 直接创建的业务对象。已链接到 `TeamTask` 的 Feature Issue 仍然是任务。

## 鉴权

`credentials/novix-credentials.json` 里是当前用户创建的 `AGENT` session cookie。它不提升权限，不应提交到仓库、聊天记录或公开日志。凭证已过期或被撤销后不能自助续证，请让用户在网页端重新更新凭证。

Helper 在发送凭证前拒绝公网 HTTP 地址，并停止自动跟随重定向；本地 `localhost`、`127.0.0.1`、`::1` 开发地址除外。

## 示例

```bash
python scripts/novix_api.py capabilities
python scripts/novix_api.py summary --search requirement
python scripts/novix_api.py request GET /api/tasks --query scope=mine
python scripts/novix_api.py request GET /api/tasks/123/actions
python scripts/novix_api.py request POST /api/tasks/123/actions/submit_testing --json action.json
python scripts/novix_api.py request GET /api/tasks/123/pull-request-candidates
python scripts/novix_api.py request POST /api/tasks/123/pull-requests --json pr-link.json
python scripts/novix_api.py request POST /api/uploads/images --file ./evidence.png --query filename=evidence.png
python scripts/novix_api.py request POST /api/workflow-tasks/123/evidence --json workflow-evidence.json
python scripts/novix_api.py request POST /api/tasks/123/evidence-comments --json evidence.json
```
