# Single-user repository: collapse user identity into modules/home

## Status

Accepted

## Date

2026-07-16

## Context

This repository manages a single NixOS user (`zine`) across potentially multiple hosts. ADR-0003 previously placed user identity (`home.username`, `home.homeDirectory`) in a per-user `users/<username>/default.nix` layer, which assumed the repository might one day support multiple users. After review, we concluded that:

- Only one user will ever exist in this repository.
- Multiple hosts remain possible and should still be supported by `hosts/<hostname>/` modules.
- The `users/<username>/` directory adds indirection without value for a single-user setup.

## Decision

Remove the multi-user abstraction layer and hardcode the single user identity:

- Delete `users/zine/default.nix` and the `users/` directory.
- Move `home.username = "zine"` and `home.homeDirectory = "/home/zine"` into `modules/home/default.nix`.
- Wire Home Manager directly in each host module: `home-manager.users.zine = import ../../modules/home`.
- Hardcode the NixOS user account as `users.users.zine` in `modules/nixos/users.nix` instead of reading from `vars.linux.user.name`.
- Remove `vars.linux.user.name` from `vars/default.nix`.
- Supersede ADR-0003 with this record.

The `modules/home/` layer remains the single source of truth for user-level configuration, and host modules remain responsible for system-level, per-machine differences.

## Alternatives Considered

### Keep `users/<username>/default.nix`

- Pros: Retains ability to add another user later without structural changes.
- Cons: Per-user directory and `vars.linux.user.name` indirection add noise for a single-user repository; the indirection also hides the fact that only one user is supported.
- Rejected: The repository explicitly targets a single user, and multi-host support is the remaining dimension of variability.

### Parameterize the username via `vars` or `extraSpecialArgs`

- Pros: Centralizes the username for all host modules.
- Cons: Still reserves a single variable for what is effectively a constant; `home-manager.users.<username>` and `users.users.<username>` are clearer when hardcoded to `zine`.
- Rejected: For a single user, a parameter is unnecessary abstraction.

## Consequences

- Simpler directory structure: one fewer layer between host modules and shared home configuration.
- Adding a second user would require reintroducing a per-user entry layer or duplicating settings; this is acceptable because the repository is committed to a single user.
- Host modules remain host-specific; no user-specific state leaks into the `vars` abstraction.
- Future agents no longer need to reason about `users/<username>/` or `vars.linux.user.name` when modifying user settings.
