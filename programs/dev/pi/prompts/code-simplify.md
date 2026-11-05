---
description: Simplify code without changing behaviour, and revert any simplification that breaks the tests
argument-hint: "[path or scope, defaults to the last change]"
---

Invoke the `code-simplification` skill.

## Routing

| Situation | Skill |
|---|---|
| Simplifying code that already works | `code-simplification` |
| Looking for refactoring candidates before simplifying anything | `/refactor`, which surveys every dimension |
| Comments explain what the code does rather than why | `no-comments` |

## What this command fixes

The skill owns the principles, the process, and the verification. Two things it leaves open:

- **Scope.** `$1` when given. Otherwise the files in the most recent change (`jj diff --stat`) plus the files that call them. State the scope before touching anything.
- **Change boundary.** This is a refactoring change and it never carries a feature or a fix. When the working copy already holds unrelated work, run `jj new` first so the simplification sits in its own change.

## Finishing

Report the simplifications kept, the ones reverted and why, and the test output for the final state. A simplification whose tests fail is reverted, not repaired inside this command.
