---
description: Break a spec into tracer-bullet tickets with blocking edges and publish them
argument-hint: "[spec issue number, URL, or path; omit to use this conversation]"
---

Invoke the `to-tickets` skill.

The source is `$1` when given, otherwise the spec already in this conversation.

## Routing

| Situation | Skill |
|---|---|
| The spec is settled and the work needs slicing | `to-tickets` |
| A task is too large because it is too shallow | `sharpen` |
| A ticket cannot be written until someone decides something | `to-questionnaire` |
| The work spans several sessions and needs a decision map | `wayfinder` |
| Issues and incoming changes need ordering before planning | `triage` |

## Two things this command fixes

Stop and ask when unchecked tickets for this feature already exist. Never silently overwrite an incomplete plan.

Publish in dependency order, blockers first, so each ticket's blocking edges can name real identifiers.

## Finishing

Report the ticket identifiers and the tickets whose blockers are all done, since those can start now. Do not start implementing.
