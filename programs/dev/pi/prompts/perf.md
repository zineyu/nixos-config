---
description: Vet a performance number before you report it or act on it
argument-hint: "[the claim, or the change you are about to measure]"
---

Invoke the `benchmark-checklist` skill.

## Routing

One skill covers this command: `benchmark-checklist`. It carries the seven questions and the
report shape. This command only decides when to enter it.

## When to enter it

- you are about to report a speedup, a regression, or a choice between options
- a plan, a review, or a change description quotes a number nobody measured

Do not enter when correctness is the open question. That is `/test` or `/review`.

## Two rules this command adds

- Write the claim sentence before the run, in the words you would ship.
- For a choice between options, every side is tuned the way production runs it. An untuned side makes the run a comparison of configurations, not of implementations, and no winner comes out of it.

## Output

Verdict first: faster, slower, no measurable difference, or inconclusive. Then the number with its unit, the run count, the range, and the limiter. When the limiter cannot be named, the verdict is inconclusive and the report says so.
