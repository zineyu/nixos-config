---
name: jujutsu
description: Work with changes in a Jujutsu repository. Use when you start work in a jj repository, when you choose between the edit workflow and the squash workflow, when you split or combine changes, and when you prepare changes for review or for a push.
---

# Jujutsu

Jujutsu has no staging area. Every commit is a change, and the working copy is itself a change.

## At the start of the work

Run `jj status` and `jj log`. Confirm three facts: the working copy has no unmerged conflict, the parent commit builds, and the test suite passes.

When the base is already broken, record that fact before you change anything, and work from the closest parent that is known to be good.

## Choose the workflow before you write code

Two workflows. Choose one at the start of the work, not at the end.

**Edit workflow — revision in place.**
Applies to one logical problem inside the most recent change: a missing test, a defect that the change introduced, or a refactor of its implementation.
Procedure: create every planned change first, then use `jj edit <change>` to move to the target change and modify it there.

**Squash workflow — split and combine.**
Applies when the work is spread over several temporary changes and must become atomic changes.
Procedure: describe each small step as you finish it, then combine the steps with `jj squash` into a few larger changes.

## Atomic changes

Each change does one thing, and satisfies four conditions:

- The change can be reverted and cherry-picked on its own, without a build error and without a logic defect.
- The title alone tells the reviewer the full impact of the change.
- The change contains no dead code, no debug output, and no unfinished work that only a comment marks.
- Formatting and refactoring are separate changes, and each change builds and passes the tests on its own.

Modify only the changes that you created and have not pushed. Do not put an unrelated edit into another person's change, and do not put an unrelated edit into a historical change.

## Before review and before a push

- `jj log` shows only atomic changes, and each description states the impact of the change.
- `jj diff --stat` contains no unrelated file.
- Each bookmark points at the intended change.
