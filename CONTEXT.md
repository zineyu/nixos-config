# Personal NixOS configuration context

This repository builds complete NixOS and nix-darwin systems for personal
machines, using a single flake that combines system-level modules with
user-level Home Manager modules. Pure software lives in `programs/`; system-side
configuration lives in `modules/`.

## Language

**Host Inventory**:
The structured mapping in `hosts/default.nix` from hostname to build metadata
(`system`, `kind`, optional `homeStateVersion`, optional `deploy`). `flake.nix`
consumes it to build one system per host.
_Avoid_: host registry, hosts file, list.

**Host**:
A single machine configuration, represented by `hosts/<hostname>/`. It holds
that machine's system-level overrides only.
_Avoid_: machine, device, node.

**User Environment**:
The Home Manager configuration of the single user `zine`. `lib/mkSystem.nix`
wires the Base Layer and the Program Modules into `home-manager.users.zine` from
`home/<hostname>.nix` when that file exists.
_Avoid_: user entry, profile, `users/<username>/`.

**Machine File**:
`home/<hostname>.nix`. It imports only the machine-specific layers (e.g. the
desktop layer) and sets `zine.programs.*` and `zine.services.*` switches. It
holds no configuration of its own.
_Avoid_: host file, organization file, home module.

**Program Module**:
A self-contained directory `programs/<category>/<name>/`. It declares
`zine.programs.<name>.enable` and owns that program's installation and
configuration, both gated on the option. Native configuration files and an
optional `package.nix` live in the same directory.
_Avoid_: package config, app config, install side, entry.

**Category**:
One of `shell`, `terminal`, `dev`, `gui`, `misc` under `programs/`. Categories
group by kind of software, never by platform.
_Avoid_: group, bundle, platform.

**Package Recipe**:
`package.nix` inside a program directory (or, for a package consumed by a system
module, inside its system module directory). The flake exposes it as
`.#<directory-name>`, which is also the name `nix-update --flake <name>` uses.
_Avoid_: custom package, pkgs entry, derivation file.

**Base Layer**:
`modules/base/`, the platform-independent Home Manager layer: state version,
agent skills and user-level services. `lib/mkSystem.nix` adds it to every User
Environment, so machine files never import it.
_Avoid_: common home, shared user layer, `modules/home`.

**Desktop Layer**:
`modules/desktop/`. Its `home/` half is the user-level Wayland desktop (niri,
DankMaterialShell, fonts, icon theme, XDG user dirs); its `system/` half is the
matching NixOS configuration (greetd, portal, audio, graphics, input method,
nixpak, Steam). Import activates the layer; it has no switch.
_Avoid_: DE, WM config, desktop stack.

**System Module**:
A module under `modules/nixos/` or `modules/darwin/`, keyed by platform. It
configures the machine, not the user.
_Avoid_: platform config, host layer.

## Example dialogue

> **Explorer**: I want to add a new keyboard daemon for the desktop host. Where
> does it go?
>
> **Maintainer**: If it is software the user runs, create a Program Module under
> `programs/<category>/<name>/` and enable `zine.programs.<name>` in the Machine
> File. If it is a system service, put it in `modules/nixos/` and import it from
> the Host.
>
> **Explorer**: Where does a user-level systemd timer go?
>
> **Maintainer**: `modules/base/services/`, behind a `zine.services.<name>`
> switch, and enabled in the Machine File.
>
> **Explorer**: Why is `ccache` only enabled on `tianxuan`?
>
> **Maintainer**: Because `macbook-air-01` is Darwin and `ccache` pulls a
> Linux-only build input. With one option per program, that is one line in the
> Machine File instead of a bundle that fails to evaluate.
>
> **Explorer**: What is the difference between a Host and a Machine File?
>
> **Maintainer**: The Host is system-level. The Machine File selects the
> user-level software for that same machine. `lib/mkSystem.nix` connects them.
