# Personal NixOS configuration context

This repository builds complete NixOS and nix-darwin systems for personal
machines, using a single flake that combines system-level modules and
user-level Home Manager modules.

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
The Home Manager configuration of the single user `zine`, wired by
`lib/mkSystem.nix` from `home/<hostname>.nix` when that file exists.
_Avoid_: user entry, profile, `users/<username>/`.

**Machine File**:
`home/<hostname>.nix`. It imports the shared user layer and the optional
desktop layer, then sets `zine.programs.*`, `zine.bundles.*` and
`zine.services.*` switches. It holds no configuration of its own.
_Avoid_: host file, organization file, home module.

**Shared User Layer**:
`modules/home/`, imported by every machine file through
`modules/home/default.nix`. Its modules define software but enable nothing by
default.
_Avoid_: base config, common home.

**Program Module**:
A self-contained directory `modules/home/programs/<category>/<name>/`. It
declares `zine.programs.<name>.enable` and owns that program's installation and
configuration, both gated on the option. Native configuration files live in the
same directory.
_Avoid_: package config, app config, install side.

**Bundle**:
`modules/home/bundles/<name>.nix`. It declares `zine.bundles.<name>.enable` and
installs a group of leaf packages that need no configuration.
_Avoid_: package list, tools file.

**Desktop Layer**:
`modules/home/desktop/`, imported only by machines that run a Wayland desktop.
Import activates the layer; it has no switch.
_Avoid_: DE, WM config.

## Example dialogue

> **Explorer**: I want to add a new keyboard daemon for the desktop host. Where
> does it go?
>
> **Maintainer**: If it needs no configuration, add the package to the matching
> Bundle. If it needs configuration, create a Program Module and enable
> `zine.programs.<name>` in the Machine File. If it is a system service, put it
> in `modules/nixos/` and import it from the Host.
>
> **Explorer**: Where does a user-level systemd timer go?
>
> **Maintainer**: `modules/home/services/`, behind a `zine.services.<name>`
> switch, and enabled in the Machine File.
>
> **Explorer**: What is the difference between a Host and a Machine File?
>
> **Maintainer**: The Host is system-level. The Machine File selects the
> user-level software for that same machine. `lib/mkSystem.nix` connects them.
