---
name: shipping-and-launch
description: Prepare a deployment so it is reversible, observable, and incremental. Use when deploying to an environment someone depends on, when asking what must be in place before shipping, when a release replaces a running version, or when you need a rollback plan.
license: MIT
metadata:
  credits:
    skill: shipping-and-launch
    author: Addy Osmani
    organisation: addyosmani
    url: "https://github.com/addyosmani/agent-skills/blob/main/skills/shipping-and-launch/SKILL.md"
---

# Shipping and Launch

## Overview

The goal is not to deploy. It is to deploy with a restore point ready, a way to see what happened, and a stated definition of success. Every launch is reversible, observable, and incremental.

## When to Use

- deploying to an environment other people or other machines depend on
- a release that replaces a running version
- a change to the configuration, secrets, or data the deployment carries
- any deployment that carries risk, which is all of them

**When NOT to use:**

- a documentation-only edit
- an artifact that is built and never run
- a deployment already governed by a process you must follow instead; read that process first

## The pre-launch checklist

### The artifact

- [ ] the build passes from a committed tree. An uncommitted working copy is not a release
- [ ] the artifact is reproducible: the same input produces the same output
- [ ] the version or revision is recorded where you can read it after the fact

### Configuration and secrets

- [ ] every new secret arrives through the secret store, never through the repository
- [ ] the configuration differences between environments are stated, not assumed
- [ ] state a rollback cannot restore is backed up before activation

### The target

- [ ] the target answers before the deploy
- [ ] the deployment path matches how that target is reached
- [ ] the components this change touches are named, one by one

### Documentation

- [ ] the documentation that describes the deployment is still true
- [ ] a decision that is hard to reverse is recorded
- [ ] the change description states what a reader needs to undo it

## The rollout sequence

One target at a time. The target you can least afford to lose goes last. Where the platform supports it, shift traffic in steps and name the signal that stops the shift.

A personal or internal target verifies that the artifact is right. A shared target verifies that it is available as well. The two need different evidence.

## Monitoring

Name the signals before the deploy, then watch those:

1. the target answers on its usual address
2. the new version is the running one
3. the components this change touched are healthy
4. the log for the one that failed, when one did

Activate nothing you cannot reach afterwards.

## Rollback

Record the restore point before activation. Rollback means returning the target to that point, and reporting which point you returned to. A rollback that nobody has executed is a plan, not a capability.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It builds, so it works" | A build is not a run. An artifact that builds can still fail on start. |
| "The configuration is declarative, so it cannot break" | The configuration is declarative; the processes it starts are not. A wrong port, a missing secret, or a changed unit fails at activation. |
| "Rollback is just another deploy" | Only if a prior restore point is recorded and still bootable. That is why you record it first. |
| "Nobody else uses this" | The environment holds your work. Losing it costs the same as losing a shared one. |
| "I will watch it after the deploy" | Then say which signal you will watch and for how long, and watch that. |
| "The secret is already in the artifact" | An artifact is readable by everyone who can fetch it. That is exposure, not convenience. |

## Red Flags

- activating with no restore point recorded
- an artifact that was never run before the switch
- a plaintext secret inside the build output
- a configuration change bundled with an unrelated release
- deploying several targets in one step
- reporting success before the target answers

## Verification

Before activation:

- [ ] the pre-launch checklist is complete for every section that applies
- [ ] the restore point is recorded
- [ ] the success signal is named

After activation:

- [ ] the target answers on its usual address
- [ ] the new version is the running one
- [ ] the components this change touched are healthy
- [ ] the log shows no new failure for those components

## Related skills

[`principle-make-operations-idempotent`](../../principles/principle-make-operations-idempotent/SKILL.md)
