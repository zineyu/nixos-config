---
description: Ship one host to production or to the test build — verify first, activate only on explicit approval
argument-hint: "<host> [check]"
---

Invoke the `shipping-and-launch` skill.

It supplies the pre-launch checklist, the rollout sequence, the monitoring order, and the rollback procedure. This command supplies the two modes, the recipes, and the one gate.

## Routing

| Situation | Skill |
|---|---|
| Deploying, or asking what must be in place first | `shipping-and-launch` |
| The deployed behaviour must be visible after the fact | `observability-and-instrumentation` |
| The change is ready and needs a pull request body | `pr` |

## Modes

- `/ship <host> check` builds and verifies without touching any machine. This is the test path.
- `/ship <host>` activates. That is production, and it is irreversible without a rollback.

`$1` must appear in `hosts/default.nix`. Do not invent an environment name: a host with `deploy.enable` is reached over the network, every other host is switched in place.

## Recipes

| Step | Command |
|---|---|
| Verify | `just check` |
| Build | `just build <host>`, or `just build-darwin <host>` |
| Remote deploy | `just deploy <host>`, after `just push-cachix <host>` on a slow link |
| In place | `just switch <host>`, or `just switch-darwin <host>` |

## The gate

Before activation, state the host, the mode, and the generation being replaced, and record that generation. Wait for an unambiguous affirmative; a hedged reply is not approval. `check` needs no gate.
