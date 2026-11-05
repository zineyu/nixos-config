---
description: Test a finished change against the real artifact and the reach beyond its diff
argument-hint: "[the change, ticket, or behaviour to test]"
---

Invoke the `principle-prove-it-works` skill, then `blast-radius`.

This command runs **after** the code is written. Development-time red-green belongs to `/build` and the `tdd` skill; reading the diff belongs to `/review`. Here the code already exists and the question is whether it works.

## Routing

| Situation | Skill |
|---|---|
| Proving the change works against the real artifact | `principle-prove-it-works` |
| The change can break callers or config beyond its diff | `blast-radius` |
| The repository cannot be driven the way a user would | `create-verification-skill` |
| A critical invariant needs a proof, not a sample | `create-formal-verification-skill` |
| A verification skill has drifted from the code | `maintain-verification-skill` |

## Two questions

1. **Does it work?** From `principle-prove-it-works`: run the real thing — the command, the page, the host, the script. Read the actual value. A passing compile, a self-report, or a proxy is not evidence. Verify against the real artifact.
2. **What else did it reach?** From `blast-radius`: name the callers of a changed interface, the shared state, the configuration, and the other hosts a change of this shape can touch. Run the real code for each safety claim you intend to make.

## Sequence

1. State what "works" means for this change in observable terms, before testing anything.
2. Run it. Record the exact command and its output.
3. Run the adjacent paths the change can break: the callers of a changed interface, the sibling configuration of a changed module, the other host that shares the module.
4. Report every claim as verified or unverified, with the evidence for the first and the reason for the second.

## Unverified is a result

A claim you could not test is reported as unverified, never as passing. Say what blocked it and what evidence would settle it.

## When a gap turns up

Fix it through `/build`, which runs the red-green loop. This command tests what exists; it does not develop new behaviour.

## When there is nothing to drive

If the repository has no way to exercise itself the way a user would, `create-verification-skill` builds one. That is its own session, not a step here.
