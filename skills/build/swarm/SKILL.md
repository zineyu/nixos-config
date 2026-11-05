---
name: swarm
description: "Fan out N parallel workers over independent slices, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage and exploration. For N candidates at one task, use arena instead."
disable-model-invocation: true
---

# Swarm

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the slices. Each worker gets one slice, and each brief stands alone. When several workers should attempt the same task so that one result can be kept or the parts of the losers grafted in, that is the `arena` skill, not this one.
3. Pick the workers. One worker per slice, all on the parent model: leave `model` unset.
4. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers with pi's `subagent` tool, one `worker` role each. The call returns immediately and each result is delivered back automatically, so the parent stays free while they run. Give each worker its own worktree or output path when it writes.

When a worker must start from a non-default pushed branch, pass `cloud_base_branch`.

**Harness.** If pi's `subagent` tool is unavailable, run the workers yourself, one after another, each with its own output path.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. Do not paste raw worker dumps.

## Phase D: Report

Return one consolidated in-chat report with a result table, issue one-liners, and gaps or dropouts.

## Presenting it

When the findings are numerous enough to skim, or the comparison is the point, present them with
[`html-report`](../../tools/html-report/SKILL.md).

## Related skills

[`arena`](../arena/SKILL.md) · [`principle-separate-before-serializing-shared-state`](../../principles/principle-separate-before-serializing-shared-state/SKILL.md) · [`html-report`](../../tools/html-report/SKILL.md) · [`principle-build-the-lever`](../../principles/principle-build-the-lever/SKILL.md)
