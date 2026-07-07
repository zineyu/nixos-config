# Personal NixOS configuration context

This repository builds complete NixOS systems for personal machines, using a single flake that combines system-level NixOS modules and user-level Home Manager modules.

## Language

**Host Registry**:
The explicit mapping of hostname to system in `hosts/default.nix`, for example `{ tianxuan = "x86_64-linux"; }`. `flake.nix` consumes this mapping to build one NixOS system per host.
_Avoid_: hosts file, registry map, list.

**Host**:
A single NixOS machine configuration, represented by `hosts/<hostname>/default.nix`. It is a NixOS module, imports `configuration.nix` from the same directory, and declares which user(s) belong to that machine.
_Avoid_: machine, device, node.

**User**:
A Home Manager user entry, represented by `users/<username>/default.nix`. It imports the shared Home Manager modules and sets its own identity (`home.username`, `home.homeDirectory`).
_Avoid_: account, profile.

**Shared Home**:
The common Home Manager modules under `modules/home/` that are imported by every user entry.
_Avoid_: common config, base config.

**Program Module**:
A per-program configuration directory under `modules/home/programs/<name>/`, containing both the module that enables the program and its native configuration files.
_Avoid_: package config, app config.

**Desktop Module**:
User-level desktop environment components under `modules/home/desktop/`, including compositor, greeter, and authentication-agent wiring.
_Avoid_: DE, WM config.

**Shell Module**:
User shell configuration under `modules/home/shell/`, covering fish, bash, and starship.
_Avoid_: shell config (too generic).

## Example dialogue

> **Explorer**: I want to add a new keyboard daemon for the desktop host. Where does it go?
> **Maintainer**: If it is a user-level daemon, put it in the relevant Desktop Module or Program Module. If it is system-wide, it belongs in the Host's `configuration.nix` or a NixOS module imported by the host.
>
> **Explorer**: What is the difference between a Host and a User?
> **Maintainer**: A Host is a NixOS machine configuration; a User is a Home Manager entry. The flake wires one Host to one User, but the two are defined separately so that shared home modules can be reused if the repo ever supports multiple users.
