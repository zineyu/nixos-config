---
name: retro
description: "Retrospective on a coding session: improve the agent's environment, not only this run's result. Manual single pass, or the deep pass with three parallel review subagents. Use for /retro, and when the user says reflect."
disable-model-invocation: true
---

# Retro

The user has asked for a **retrospective**. Suggest improvements to the coding agent's **environment**, so the next run is better than this one.

Two modes answer the same question. Pick one before you start, and say which you picked.

| Mode | Who does the work | Output | Edits skills? |
|---|---|---|---|
| **manual** | the parent agent, one pass | ranked candidates the user chooses from | no |
| **deep** | three review subagents, then a synthesiser | accepted findings, each routed to an edit on an existing skill | only after explicit approval |

Choose `deep` when the user says "reflect", when the session taught something about how to work rather than what to build, or when a skill should have triggered and did not. Choose `manual` for everything else. Skip both when the session is trivial, off-topic, or already covered by a skill that the parent followed correctly: a one-off is not a learning.

## 1. Collect the record

The record is the run, not your memory of it. Read the primary sources: the transcript, the changes (`jj log`, `jj diff`, `git log`), the gate output, and any review report.

Where the transcript lives depends on the harness:

- **Claude Code:** `~/.claude/projects/<slug>/<session-id>.jsonl`, where `<slug>` is the workspace path with every character that isn't a letter or digit turned into "-".
- **Pi:** `~/.pi/agent/sessions/--<slug>--/*.jsonl`, where `<slug>` is the workspace path with the leading slash dropped and each "/" turned into "-".
- **Codex:** `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. Keep only files whose first line has `payload.cwd` equal to the workspace path.
- **Other harnesses:** check the harness's session directory for this workspace.

Stay inside the active workspace: do not glob across every project's session directory, because that reads private chats from unrelated projects. Take the newest candidates first, and confirm one by finding the conversation's opening user prompt in its first user message. If none matches, pass a tight digest of the session instead.

## 2. Manual mode

Call the Skill tool with `writing-for-agents` first: everything this mode recommends gets written in that style.

Look for candidates in these categories, and use one only when its trigger applies:

- **Navigation**: how easy was it for the agent to find the right files? Are there hidden dependencies between files? Would a **navigation pointer** make it easier? _Use when_ the session took a long time to find a piece of information.
- **Automated checks**: are there automated checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? Read the repo's own check command first (its `package.json`/build-tool `lint`/`check` scripts, its CI workflow), so a check that already exists but sits unwired or silently broken is the finding, not a reinvention. A repo with no **guardrail** (no pre-commit hook and no CI job running its lint/typecheck/test command) is itself a finding: an un-linted repo is a standing missed opportunity, not a neutral default. _Use when_ the agent made a mistake an automated check could have caught, or the repo has no guardrail at all.
- **Coding standards**: should the **reviewer agent** be given a new rule to enforce? Should an existing rule be removed or clarified? Classify the violation first: a **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop: a custom rule in the repo's own linter, a new pre-commit hook, or a new CI job, whichever the repo's language and existing guardrail make cheapest. Default to building the check over writing the rule. Reserve `CODING_STANDARDS.md` for genuine **judgement calls** (cross-file consistency, "matches the surrounding style," anything no guardrail could ever substitute for). _Use when_ the reviewer agent failed to catch a mistake. A correction the operator has already made twice is the [`correct`](../../gate/correct/SKILL.md) skill's job, not a new line in a standards file.
- **Global AGENTS.md**: are there any steering instructions that should be moved to coding standards (or automated checks) instead? _Use when_ the AGENTS.md file is particularly large, in the repo OR the user's global scope.
- **Tool economy**: did the agent make expensive tool calls that could be streamlined? Is there any custom tooling (CLIs, MCPs) that is particularly token-inefficient? _Use when_ the agent made an expensive tool call.
- **No-ops**: look for instructions in steering files that don't modify the agent's behavior. _Use when_ the steering files are large and unwieldy.
- **Information access**: look for opportunities to increase the agent's access to information. Teeing dev server logs, readonly access to third-party services. _Use when_ a crucial piece of information was not available to the agent.

Present the candidates to the user, in order of severity. This mode writes nothing.

## 3. Deep mode

### 3.1 Spawn three reviewers in parallel

One message, three `scout` subagent calls. Reviewers need whatever MCP servers the transcript references, so do not deny them those tools.

**Harness.** If pi's `subagent` tool is unavailable, run each role yourself, one after another, and keep the bulk of the reading out of the main thread (see [`principle-guard-the-context-window`](../../principles/principle-guard-the-context-window/SKILL.md)).

Spawn with pi's `subagent` tool. Leave `model` unset so each subagent runs on its configured default, except where this table names one.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `grok-4.7-xhigh-fast` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Task` response body.

### 3.2 Synthesize

One `worker` subagent call, `model` unset. It spot-verifies citations through the MCP servers it needs. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

### 3.3 Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the [`principle-encode-lessons-in-structure`](../../principles/principle-encode-lessons-in-structure/SKILL.md) skill.

### 3.4 Apply

Present the synthesiser's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to your harness's skill-authoring skill and run its draft / test / iterate loop. Use Anthropic's `skill-creator` when installed, and follow the Agent Skills format at agentskills.io plus [`writing-for-agents`](../writing-for-agents/SKILL.md). "`create-skill`" below means whichever of these you use.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `create-skill` and run its description-optimization loop.
- `new skill via create-skill: <kebab-name>`: hand creation to `create-skill`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

### 3.5 Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding and the reason from the synthesiser.

## Reference

### Implementation vs Review

All work goes through two stages: implementation and review. The implementation agent has the most **context pressure**. It is responsible for exploration, writing code, and debugging failures.

The review agent has the least context pressure: it receives a diff, so no exploration is needed. It often does not need to write code or debug.

This means that the review agent should be responsible for imposing coding standards, not the implementation agent.

### Files

- `CLAUDE.md`/`AGENTS.md`: these files are pushed to the context window of any agent working in this repo. Use them sparingly, usually only for **navigation pointers** to other files.
- `CODING_STANDARDS.md`: this file is read during review, not implementation. Add **navigation pointers** to docs folders if the standards file gets more than 1,000 lines long.
- Docs: use docs as reference files, pointed to by other files. Look for existing docs before writing new ones.
- Skills: use skills for docs (since their description goes into the agent's context window), or for user-invoked commands. Follow the advice in the [`writing-for-agents`](../writing-for-agents/SKILL.md) skill.

### Where a skill edit lands

Never edit a skill under `plugins/cache/`. Before approval, show its destination: this repo's `skills/<category>/<skill>/`, or the user skill folder `~/.agents/skills/<skill>/`. After approval, copy the skill folder there and edit the copy. Never open a PR or push.

## Presenting it

When the findings are numerous enough to skim, or the comparison is the point, present them with
[`html-report`](../html-report/SKILL.md).

## Related skills

[`correct`](../../gate/correct/SKILL.md) · [`principle-encode-lessons-in-structure`](../../principles/principle-encode-lessons-in-structure/SKILL.md) · [`second-pass`](../../review/second-pass/SKILL.md) · [`html-report`](../html-report/SKILL.md)
