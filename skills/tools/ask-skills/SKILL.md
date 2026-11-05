---
name: ask-skills
description: Route to what the commands do not cover — paths that cross between them, and skills that stand alone.
disable-model-invocation: true
---

# Ask Skills

The commands own the main line and each carries its own `## Routing` table. Read this when you are
between steps, or when what you need does not belong to any single one of them.

## The main line

`/spec` → `/plan` → `/build` → `/test` → `/review` → `/code-simplify` → `/gate` → `/ship`, with
`/perf` beside them for any number you report.

## Paths that cross commands

| Situation | Path |
|---|---|
| A question needs a runnable answer | `/spec` → `handoff` out → `prototype` → `handoff` back → `/spec` |
| The reading is too large to do here | `research` in a background subagent, then bring the cited file into `/spec` |
| The blocker lives in someone else's head | `to-questionnaire`, then back into `/spec` |
| A message did not land | `wait-what`, mid-conversation, inside any skill |
| A spare moment to make the codebase easier to work in | `improve-codebase-architecture`, then take a finding into `/spec` |
| A term is fuzzy or overloaded | `domain-modeling`, which `/spec` also drives |

Where a phase inside one session ends and which of the five ways to cross it fits, see
[PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md).

## Skills that stand alone

- `triage` pushes incoming issues and changes to a decision
- `retro` improves the agent's environment after a session, in a manual pass or a deep pass with review subagents
- `automate-me` turns a way of working into a `-mode` skill
- `show-me-your-work` leaves a reviewable trail of decisions during a long run
- `ketchup` says what happened since your last message, in plain words
- `teach` keeps a subject in one workspace over weeks
- `technical-writing` and `unslop` set prose standards, for humans and against AI cadence
- `wizard` generates an interactive script for steps only a human can take
- `setup-skills` configures the tracker, labels, and doc layout once
- `find-skill` discovers and installs a skill from outside this repository
- `jujutsu` is the version-control workflow itself
- `novix-worktrace-agent` collaborates in NovixWorkTrace under the current user's permissions

## Principles and tools

`principles/` holds cross-cutting judgement; skills cite a principle by name instead of restating
it. `tools/` holds repository machinery. Neither is a step in the lifecycle.
