# Glossary

The canonical language of this repository. Every term used in `CONTEXT.md`, the ADRs, the
commands, and the skills follows this list. Use the term as written here, and avoid the words
listed under `_Avoid_`.

**Broadcast-and-Gate**:
The composition model of this repository (ADR-0014). Every module tree is imported by every
host of its platform; each module then decides for itself whether to activate, by reading
**Host Metadata**. A Host never lists what it imports, and never writes a switch for
something its own metadata already implies.
_Avoid_: opt-in modules, feature flags, plugin architecture.

**Host Metadata**:
The typed projection of a Host Inventory entry, delivered to every module as the `host`
specialArg (`host.name`, `host.kind`, `host.system`, `host.tags`, `host.gates`,
`host.userEnvironment`) and mirrored read-only as `zine.host`. Gates read `host.gates`;
`zine.host` exists for validation, `nix eval` auditing, and cross-tag assertions.
_Avoid_: host config, host vars, machine profile.

**Tag**:
One label in a Host Inventory entry, drawn from the closed vocabulary registered in
`modules/host-metadata.nix`. A tag must be a property of the machine — machine form
(`desktop`, `server`, `wsl`), session (`gui`), or system capability (`docker`, `tailscale`,
`nvidia`, `mihomo`). Software groupings are not admissible: a tag that exists to reproduce
an old program list is that list with worse ergonomics. An unknown tag fails evaluation.
`host.gates.<tag>` is its boolean projection, and that is what gates read.
_Avoid_: flag, label, feature, marker.

**Gate**:
The `lib.optionals` / `lib.mkIf` expression that turns a Tag into a decision, written as
`host.gates.<tag>` — a boolean projection of `host.tags`, total over the vocabulary, so a
misspelled tag is an evaluation error instead of a silent `false`. A gate may sit at a tree
entry (`imports`) or inside a leaf module; both read the same specialArg.
_Avoid_: condition, predicate, enabled flag.

**Host Inventory**:
The structured mapping in `hosts/inventory.nix` from hostname to host metadata: `system`,
`kind`, `tags`, `userEnvironment`, optional `homeStateVersion`, optional
`deploy`. It is the single source of every host difference; `flake.nix` consumes it to build
one system per host and to generate deploy-rs nodes.
_Avoid_: host registry, hosts file, list.

**Host**:
A single machine configuration, represented by `hosts/<hostname>/`: `default.nix` for system
facts, an optional `home.nix` for User Environment overrides, and
`hardware-configuration.nix`. It holds no capability decisions, because those are Tags.
_Avoid_: machine, device, node.

**User Environment**:
The Home Manager configuration of the single user `zine`. `lib/mkSystem.nix` wires the Base
Layer, the Program Modules and the Desktop Layer into `home-manager.users.zine` for every
host whose Host Inventory entry sets `userEnvironment = true`, importing that host's
`hosts/<hostname>/home.nix`. Absence is declared in metadata, never inferred from a missing
file.
_Avoid_: user entry, profile, `users/<username>/`.

**Machine File**:
`hosts/<hostname>/home.nix`. A Machine File carries only overrides that are genuinely
machine-local and expressible nowhere else: a font size, a single package, a workaround.
Software selection lives in the Program Modules' own gates, not here. An empty Machine
File is normal; what makes the User Environment exist is `userEnvironment = true`, not the
file's presence.
_Avoid_: host file, organization file, home module, switch table.

**Program Module**:
A self-contained directory `programs/<category>/<name>/`. It owns that program's installation
and configuration, and it decides for itself whether to activate by declaring the capability
it needs: `lib.mkIf host.gates.gui`, `lib.mkIf (host.kind == "nixos")`, and so on. A program
that needs no capability is part of the User Environment baseline and is not
gated at all (`config = { … };`). Native configuration files and an optional `package.nix`
live in the same directory. Nothing lists programs per host.
_Avoid_: package config, app config, install side, entry.

**Category**:
One of `shell`, `terminal`, `dev`, `gui`, `misc` under `programs/`. Categories group by kind
of software, never by platform.
_Avoid_: group, bundle, platform.

**Package Recipe**:
`package.nix` inside a program directory (or, for a package consumed by a system module,
inside its system module directory). The flake exposes it as `.#<directory-name>`, which is
also the name `nix-update --flake <name>` uses.
_Avoid_: custom package, pkgs entry, derivation file.

**Base Layer**:
`modules/base/`, the platform-independent Home Manager layer: state version, agent skills and
user-level services, each gated on a Tag. `lib/mkSystem.nix` adds it to every User
Environment, so hosts and Machine Files never import it.
_Avoid_: common home, shared user layer, `modules/home`.

**Desktop Layer**:
`modules/desktop/`. Its `home/` half is the user-level Wayland desktop (niri,
DankMaterialShell, fonts, icon theme, XDG user dirs); its `system/` half is the matching
NixOS configuration (greetd, portal, audio, bluetooth, graphics, input method, nixpak, Steam).
Both halves gate on the `desktop` Tag, and the system half is imported wholesale because the
third-party modules it pulls in cannot deactivate themselves.
_Avoid_: DE, WM config, desktop stack.

**System Module**:
A module under `modules/nixos/` or `modules/darwin/`, keyed by platform. It configures the
machine, not the user.
_Avoid_: platform config, host layer.

**System Capability**:
A module under `modules/nixos/optional/` that is inert unless the Host carries its Tag. It
declares no option: the gate is `lib.mkIf host.gates.<tag>`, so a capability
cannot drift from the metadata that decides it. Configuration that every NixOS host needs
belongs in `modules/nixos/common/`, not here.
_Avoid_: feature flag, addon, plugin.

**Command**:
A prompt template in `programs/dev/pi/prompts/`, installed as `/<name>`. It answers the *when*: which
skills run, in which order, with which arguments, behind which gate. Its `## Routing` table names the
situation that switches to another skill.
_Avoid_: entry point, slash command (use command), workflow.

**Skill**:
A directory `skills/<command>/<name>/` holding `SKILL.md`. It answers the *how*: the procedure, the
bar, and the exit criteria. `principles/` and `tools/` hold skills that no single command owns.
_Avoid_: prompt, playbook, recipe.
