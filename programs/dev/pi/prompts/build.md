---
description: Implement one ticket at a time, or the whole plan in one approved pass with "auto"
argument-hint: "[ticket-id | auto]"
---

Invoke the `implement` skill, with `tdd` for the loop and `diagnosing-bugs` when a test will not pass.

## Routing

| Situation | Skill |
|---|---|
| Implementing a ticket, test first | `implement` with `tdd` |
| A test will not pass and the cause is not obvious | `diagnosing-bugs` |
| The interface or module shape is not settled | `codebase-design`, then `architect` |
| The domain model is unclear before writing stateful logic | `domain-driven-design` |
| A design question needs running code to answer it | `prototype` |
| The behaviour is a state machine | `statechart` |
| Several candidate approaches should compete | `arena` |
| Independent slices can run in parallel | `swarm` |
| A whole spec should be driven at once | `implement-spec` |
| Reading existing code before changing it | `why`, or `how` for a subsystem |
| The files are TypeScript | `typescript-best-practices` |
| The work is user-facing UI | `frontend-ui-engineering` |

## Baseline

Run `jj status` and `jj log`. Confirm no unmerged conflict, the parent commit builds, and the suite passes. Uncommitted work outside the ticket's scope stops the run: ask the user to commit, abandon, or confirm how to handle it.

## Modes

- `/build <ticket-id>` implements that ticket, then stops.
- `/build auto` implements the frontier in dependency order: any ticket whose blockers are all done.
- `/build` with no argument names the first frontier ticket it chose, then implements it.

Automatic mode is not faster per ticket. It runs the same loop and only removes the human stepping between tickets.

## The one gate

In automatic mode, present the plan once and wait for an unambiguous affirmative. A hedged reply ("looks reasonable", "I guess") is not approval.

## Per ticket

One change per ticket, created with `jj commit` and described so the title alone states the impact. That is what makes any point a clean rollback.

## Stop and ask

- a test will not pass and the cause is not obvious
- the spec is silent on a decision the ticket needs
- the ticket is high-risk or irreversible: authentication, permissions, destructive migrations, payments, deletions, deploys, secrets

Everything else proceeds without asking, per `principle-never-block-on-the-human`: a reversible
step is taken and reported, not put back to the user as a question.

After a blocker is resolved, re-run `/build auto`; it resumes at the next ticket.

## Finishing

Report the tickets completed, the tests added, the changes created, and anything skipped or flagged.
