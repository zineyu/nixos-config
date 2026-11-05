---
description: Settle the intent, then publish the spec to the tracker
argument-hint: "[existing issue number or URL to extend]"
---

Invoke the `interview-me` and `domain-modeling` skills, then the `to-spec` skill, in that order.

## Routing

| Situation | Skill |
|---|---|
| The ask is one sentence and its goal is unclear | `in-your-own-words` |
| The intent is underspecified: no who, no why, no success, no constraint | `interview-me` |
| Terms or a hard-to-reverse trade-off will be recorded | `domain-modeling` |
| A question needs someone else's answer | `to-questionnaire` |
| The intent is confirmed and the spec must be written | `to-spec` |

## Stop at the intent, not at the tree

`interview-me` stops when you can predict the user's reaction to the next three questions you would
ask. That is the gate. The implementation decisions a spec cannot settle are not this command's
work: `/plan` slices them into tickets and `/build` stops and asks when a ticket reaches one the
spec never answered.

## Why `domain-modeling` follows

`to-spec` records decisions; it does not make them. `interview-me` settles the intent, and
`domain-modeling` writes what crystallises where this repository keeps it: a resolved term into
the `## Language` section of `CONTEXT.md`, a hard-to-reverse trade-off into `docs/adr/`. Do not
create a second glossary file.

## The coverage gate

Before synthesis, check every section the spec template needs against what the user has explicitly said:

- Problem Statement
- Solution
- User Stories
- Implementation Decisions
- Testing Decisions
- Out of Scope

`interview-me` already covers the first, second, and last, and gives the vocabulary for user
stories. Whatever remains rests on an assumption: ask it now rather than writing an open question
in its place. Facts are the exception; look them up in the repository or by dispatching a subagent.

## Finishing

With an argument, extend that existing issue. With none, open a new one. Publish with the
`ready-for-agent` label and report the issue number and title. Do not start implementing.
