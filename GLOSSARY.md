# Glossary

The canonical language of this repository. Every term used in `CONTEXT.md`, the ADRs, the
commands, and the skills follows this list. Use the term as written here, and avoid the words
listed under `_Avoid_`.

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
desktop layer), sets `zine.programs.*` and `zine.services.*` switches, and may
add a small override that is genuinely machine-local (a font size, a single
package). It never imports the Base Layer or `programs/`.
_Avoid_: host file, organization file, home module.

**Program Module**:
A self-contained directory `programs/<category>/<name>/`. It declares
`zine.programs.<name>.enable` and owns that program's installation and
configuration, both gated on the option. Native configuration files and an
optional `package.nix` live in the same directory. The directory name is the
default option name; a few predate the convention (`jj` → `jujutsu`, `zed` →
`zed-editor`, `gnupg` → `gpg`).
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

**Command**:
A prompt template in `programs/dev/pi/prompts/`, installed as `/<name>`. It answers the *when*: which
skills run, in which order, with which arguments, behind which gate. Its `## Routing` table names the
situation that switches to another skill.
_Avoid_: entry point, slash command (use command), workflow.

**Skill**:
A directory `skills/<command>/<name>/` holding `SKILL.md`. It answers the *how*: the procedure, the
bar, and the exit criteria. `principles/` and `tools/` hold skills that no single command owns.
_Avoid_: prompt, playbook, recipe.
