---
name: constraint-driven-development
description: "Write a project's quality bar down as a contract with numbers, then stop agents from quietly lowering it. Use when no quality bar exists, when the user says 'set up constraints' or 'define our standards', when an agent keeps silencing checks or skipping tests to reach green, or when a threshold is needed and no number has been chosen."
license: MIT
metadata:
  credits:
    skill: constraint-driven-development
    author: Addy Osmani
    organisation: addyosmani
    url: "https://github.com/addyosmani/agent-skills/blob/main/skills/constraint-driven-development/SKILL.md"
---

# Constraint-Driven Development

## Overview

Other skills describe what good looks like: a code review gives axes, test-driven development gives a cycle. All of that is prose the agent reads and may or may not follow, and none of it outlives the session.

This skill produces something different: a written record of **this project's** bar, with numbers, that survives the conversation and can be checked mechanically. When you write the code yourself, reading it tells you whether it is any good. An agent writes more in an afternoon than you will read that week, so the judgement moves out of your head and into checks that run around the loop.

## When to Use

- starting a project or a large change and no bar is written down
- the user asks to set up constraints, quality gates, or standards
- an agent is producing volume nobody reads line by line
- CI has checks but nobody can say which ones block a change
- a threshold is argued per change instead of decided once
- an autonomous loop is about to run, and its only gate is a check the agent also wrote

**When NOT to use:**

- `CONSTRAINTS.md` already exists and nobody is changing it: read it and follow it
- one-off scripts and throwaway prototypes
- the user wants a code review right now

## Do not run the interview alone

The interview needs a live user. In a non-interactive context, apply the Floor, say that you did, and leave the rest for a human.

## The process

### Step 1: detect before you ask

Read the manifest, the build file, the lint and formatter configuration, the test configuration, the task runner, and every CI workflow. Report what you found in two lines. Never ask for anything you can read.

### Step 2: four questions, each with a default

Ask one at a time, and give a usable default so "I don't know" still produces a working bar:

1. which dimensions beyond the floor matter here
2. block or warn when a check fails mid-task
3. the target numbers, or measure today's value and hold it
4. how slow a check may get before it leaves the loop for review

### Step 3: write CONSTRAINTS.md

Four sections, in this order:

```markdown
## Floor (always enforced, no setup required)

## Enforced with numbers
| Rule | Command | Threshold | Why this number |

## Measured, not yet enforced
| Metric | Command | Today's value |

## Exceptions
| Rule | Owner | Expires | Reason |
```

Every number carries its reason. An exception without an owner or an expiry is a rule that has been deleted.

### Step 4: install what each dimension needs

A dimension with a number and no tool behind it is an aspiration. Use the de facto tool of the ecosystem so that existing configuration keeps working, and record the exact command beside its rule.

| Dimension | What counts as the tool |
|---|---|
| Formatting | the ecosystem's formatter, run in check mode |
| Lint | the ecosystem's linter, failing by default rather than warning |
| Types and static analysis | the compiler or checker, run strict |
| Dead code | the ecosystem's dead-code pass |
| Tests | the project's own runner, named exactly |
| Coverage | the runner's coverage output, with line and branch numbers |
| Secrets | a secret scanner over the diff and the history |
| Dependencies | the package manager's native audit against the committed lockfile |

A dimension the project cannot measure is dropped from the table, not given a number.

### Step 5: place each check by cost

Seconds: formatting, lint, secrets, in the edit loop. Under ninety seconds: the related tests, at the end of a task. Everything else: at review or in CI.

### Step 6: guard the bar itself

An agent asked to reach green will reach green. Watch the diff for five moves:

1. a threshold in `CONSTRAINTS.md` edited down
2. a test made easier: skipped, deleted, or with an assertion removed
3. a silenced check: a new suppression comment, or a rule disabled in a config
4. unfinished work: a stub, an empty catch, a docstring standing in for a body
5. a new exception with no owner or no expiry

Only loosening surfaces. Tightening is silent. A guard that cannot run reports a distinct failure, never a pass.

### Step 7: ratchet

Without a number, record today's measured value as the floor that must not fall. A ratchet turns "do not make it worse" into a check.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We will add the bar once the code settles" | The bar is what makes the code settle. |
| "A warning is gentler than a block" | A warning nobody turns into an error is decoration. Choose block, or drop the rule. |
| "This threshold is arbitrary" | Then state why, or measure today and hold that. An unexplained number invites editing it down. |
| "I disabled the check to get the change through" | That is the move this skill exists to catch. Record an exception instead, with an owner and an expiry. |
| "The metric is green, so we are fine" | A green metric on a rule that does not block is a note, not a gate. |

## Red Flags

- `CONSTRAINTS.md` with numbers and no commands
- a suppression comment in the same change that made the check fail
- an exception row with no expiry
- a threshold edited in a change that did something else
- checks that exist in CI but not in the loop, or the reverse
- an agent reporting "all checks pass" without naming them

## Verification

- [ ] `CONSTRAINTS.md` exists, with a Floor section and a reason on every number
- [ ] every enforced rule names a command that runs, and that command was run once
- [ ] each rule sits at the cost level chosen in Step 5
- [ ] the guard detects the five moves, and was tried against one of them
- [ ] every exception has an owner and an expiry

## Related skills

[`principle-make-operations-idempotent`](../../principles/principle-make-operations-idempotent/SKILL.md)
