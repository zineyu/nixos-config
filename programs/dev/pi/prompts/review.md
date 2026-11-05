---
description: Review a diff along both axes and report findings by severity, with no verdict and no edits
argument-hint: "[base, defaults to main]"
---

Invoke the `code-review` skill. The base is `$1`, and defaults to `main`.

## Routing

| Situation | Skill |
|---|---|
| The default two-axis review of a diff | `code-review` |
| The change deserves more than one model attacking it | `interrogate` |
| The diff adds a second copy of logic | `code-reuse` |
| Reviewing work you just finished yourself | `second-pass` |

## What this command adds

- Both axes are dispatched in a single reply, never one after the other.
- Every finding carries a severity, `file:line`, and the fix you would make.
- Review only. Do not edit the code; this command ends with the report.

## Severity

| Tier | Meaning |
|---|---|
| Critical | Correctness, security, or data loss risk. Blocks the change. |
| Required | Breaks a documented standard, or leaves a stated requirement unmet. |
| Optional | A real improvement that the change can ship without. |
| Nit | Naming, wording, formatting. |

## Output

Lead with the counts per tier. Then one list per axis (Standards, Spec), each finding as
`severity — file:line — finding — proposed fix`. Close with the findings you could not place on
either axis, and say why.

This command stops at the findings. The verdict belongs to whoever merges the change.
