---
description: Write this repository's quality bar into CONSTRAINTS.md, then guard it against silent weakening
argument-hint: "[check | guard | ratchet]"
---

Invoke the `constraint-driven-development` skill.

It supplies the interview, the `CONSTRAINTS.md` sections, the four questions with defaults, and the five moves the guard watches for. This command supplies the entry points and where each output lands here.

## Routing

| Situation | Skill |
|---|---|
| No bar is written down and one must be chosen | `constraint-driven-development` |
| The same correction has been made twice and must stop recurring | `correct` |
| The change accepts untrusted input, touches auth, secrets, or dependencies | `security-and-hardening` |
| The change touches the pipeline or the checks themselves | `ci-cd-and-automation` |

## Where things land

- the bar: `CONSTRAINTS.md` at the repository root
- the pointer: one line in `CONTEXT.md` telling agents to read it and never weaken it to make a change pass
- the commands: one `just` recipe per check, named in that rule's row in the table

## Sub-commands

- `/gate` runs the interview and writes the bar
- `/gate check` runs every rule against the current branch, one line per rule with its exit status
- `/gate guard` scans the diff for the five moves and reports `file:line` for each
- `/gate ratchet` measures today and records the value as the floor that must not fall
