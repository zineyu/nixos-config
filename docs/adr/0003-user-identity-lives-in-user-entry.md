# User identity lives in the user entry

## Status

Superseded by ADR-0004 (single-user collapse).

## Date

2025-07-16 (original decision).

## Context

We decided that a user's identity (`home.username`, `home.homeDirectory`) belongs in `users/<username>/default.nix`, not in the flake, not in the host module, and not as a Home Manager special argument. The host module wires the user entry to `home-manager.users.<username>`, and the shared `modules/home/common.nix` no longer needs a `username` parameter. The `username` and `hostname` special arguments are removed from `home-manager.extraSpecialArgs`, leaving only `inputs`. The result is that shared Home Manager modules are no longer parameterized by the current user, and a user entry becomes self-describing.
