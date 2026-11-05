---
description: Survey the repository for refactoring candidates across architecture, layout, lint, CI, deployment, performance, abstraction, and simplification, then stop at the list
argument-hint: "[path or subsystem; empty for the whole repository]"
---

Read these skills before surveying. Each contributes one rule this command enforces.

| Skill | What it contributes here |
|---|---|
| `html-report` | the page the survey is delivered on |
| `improve-codebase-architecture` | the architecture pass |
| `codebase-design` | the deletion test, and the module / interface / seam vocabulary every candidate uses |
| `code-reuse` | when a duplicate costs less than the abstraction that would remove it |
| `code-simplification` | what a simplification candidate looks like |
| `constraint-driven-development` | the bar for the lint dimension |
| `ci-cd-and-automation` | the bar for the CI dimension |
| `shipping-and-launch` | the bar for the deployment dimension |
| `benchmark-checklist` | the bar for the performance dimension |
| `principle-laziness-protocol` | bias to deletion: the survey proposes removals, never a new layer |
| `principle-build-the-lever` | when a finding recurs across the survey, propose the script that checks it instead of repeating the check by hand |
| `principle-subtract-before-you-add` | the order of the hand-off: removal first, construction on the simpler base |
| `second-pass` | the check on your own output, before you hand the list back |

## Dimensions

| Dimension | A candidate is |
|---|---|
| Architecture | a shallow module that could be deepened behind one seam |
| Layout | a directory mixing two kinds of thing, or a file whose neighbours no longer predict it |
| Lint | a suppression, a disabled rule, or a rule that exists but never blocks |
| CI | a check in one place but not the other, or a job whose failure nobody would notice |
| Deployment | a step done from memory, or a rollback that has never been executed |
| Performance | a number nobody measured, or a claim with no limiter named |
| Abstraction | an interface with one implementation, a wrapper that only forwards, a layer that only converts types, a flag that is always true, a `utils/` function with one caller |
| Simplification | a construct that makes a new reader slow down |

The scope is `$1` when given, otherwise the whole repository.

## The abstraction pass

Enumerate before judging. Walk the scope and list every indirection, then test each one with the
deletion test from `codebase-design`: delete it in your head, and ask where the complexity goes.

- vanishes: it was a pass-through, and it is a candidate
- reappears in the callers: it was earning its place, and it is not a candidate

An abstraction that survives the test is a finding too. Report it as a proven seam, and say that an
ADR would stop a future survey from proposing it again.

`code-reuse` guards the opposite error: an abstraction that couples two contexts which could evolve
apart costs more than the duplication it removed. Read it before proposing a merge.

## Rules

- Every candidate carries evidence: `file:line`, and the friction it causes in one sentence.
- Rank by cost of delay, not by tidiness. A candidate nobody will trip over goes last.
- A decision already recorded in an ADR is not a candidate; it is the answer.
- Every candidate removes something. A survey that proposes adding a layer has broken
  `principle-laziness-protocol`.
- Do not propose interfaces, do not interview, and do not edit code. The report is the deliverable.

## Before you hand back

Run `second-pass` over the list you produced, not over the code: for each candidate, ask whether a
better version of the same removal exists, and drop the ones whose friction you cannot state in one
sentence. A shorter list of proven candidates beats a longer list of suspicions.

## Output

Invoke the `html-report` skill. It owns the page format and the rules for writing to a person.
This command adds one field per card: the **dimension** from the table above, as a badge beside the
recommendation strength, so a reader can tell an architecture candidate from a lint one.

## Hand off

A picked candidate continues at `/plan`. An abstraction to inline, or a construct to simplify,
continues at `/code-simplify`. One small enough to state in a single line continues at `/build`.

Order matters on the way out, per `principle-subtract-before-you-add`: the removal lands first, and
whatever the removal makes possible is built on the simpler base afterwards.
