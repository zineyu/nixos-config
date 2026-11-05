---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
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
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Pick the workers. One worker per slice or per arm, all on the parent model: leave `model` unset. For a model race, name each arm's model up front and pass it explicitly.
4. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers with pi's `subagent` tool, one `worker` role each. The call returns immediately and each result is delivered back automatically, so the parent stays free while they run. Give each worker its own worktree or output path when it writes.

When a worker must start from a non-default pushed branch, pass `cloud_base_branch`.

**Harness.** If pi's `subagent` tool is unavailable, run the workers yourself, one after another, each with its own output path.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

## Phase D: Report

Return one consolidated in-chat report with a result table, issue one-liners, gaps or dropouts, and the race rule when used.

## Presenting it

When the findings are numerous enough to skim, or the comparison is the point, present them with
[`html-report`](../../tools/html-report/SKILL.md).

## Related skills

[`principle-separate-before-serializing-shared-state`](../../principles/principle-separate-before-serializing-shared-state/SKILL.md) · [`html-report`](../../tools/html-report/SKILL.md) · [`principle-build-the-lever`](../../principles/principle-build-the-lever/SKILL.md)
