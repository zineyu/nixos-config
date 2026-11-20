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
specialArg. It has exactly two views (ADR-0018): `host.gates` — one boolean per Capability,
total over the vocabulary — and `host.facts`, the machine's Fact sheet. `host.tags` is *not*
part of it: tags are input syntax, visible only to the audit projection `zine.host.tags`,
which exists for validation, `nix eval` auditing, and cross-capability assertions.
_Avoid_: host config, host vars, machine profile.

**Fact**:
A machine value that comes from the world instead of from a preference: `facts.form`
(`desktop` / `laptop` / `server` / `wsl`), `facts.gpu` (vendors, PRIME bus ids), `facts.displays`.
Facts are written in the Host Inventory, are required, and are typed — a missing fact is an
evaluation error, never a default. Facts feed Capability derivation and a Knob's default
value; they are never part of the override chain.
_Avoid_: host data, hardware vars, properties, attributes.

**Capability**:
One entry of the Gate vocabulary, either *chosen* (a Tag) or *derived* (computed from Facts:
`desktop` / `server` / `wsl` from `facts.form`, `nvidia` from `facts.gpu.vendors`). The union
is total, so `host.gates.<capability>` always exists. A derived capability must never be
declared as a tag: the enum rejects it.
_Avoid_: feature, permission, flag.

**Tag**:
One *chosen* capability in a Host Inventory entry, drawn from the closed vocabulary in
`lib/host-tags.nix`: `gui`, `docker`, `sshd`, `tailscale`, `mihomo`, `remote-login`,
`headscale-backup`. A tag is a decision the hardware cannot reveal — machine form and GPU are
Facts, not tags. Software groupings are not admissible: a tag that exists to reproduce an old
program list is that list with worse ergonomics.
_Avoid_: flag, label, feature, marker, profile.

**Gate**:
The `lib.mkIf` expression that turns a Capability into a decision, written as
`host.gates.<capability>`. It sits inside a module body, never in `imports` — every host
evaluates every module, so a typo fails on all four hosts at once. Tree entries whose leaves
cannot deactivate themselves (third-party modules, `scanPaths` subtrees) are the only
exception and must carry a `lint-allow-imports-gate:` comment.
_Avoid_: condition, predicate, enabled flag, import switch.

**Knob**:
A typed option declared by the module that owns the setting, always with a default —
`zine.programs.kitty.fontSize`, `zine.<area>.<name>`. It is the only place a *degree*
difference between devices may live: a Machine File assigns knobs, and nothing else. Adding a
knob is justified only once a second device needs a different value.
_Avoid_: parameter, override, tweak, setting.

**Host Inventory**:
The structured mapping in `hosts/inventory.nix` from hostname to host metadata: `system`,
`kind`, `facts` (required), `tags`, `userEnvironment`, optional `homeStateVersion`, optional
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
`hosts/<hostname>/home.nix` when it exists. Absence of the User Environment is declared in
metadata; absence of a Machine File simply means "no degree difference on this host".
_Avoid_: user entry, profile, `users/<username>/`.

**Machine File**:
`hosts/<hostname>/home.nix`. The Machine File assigns `zine.*` Knobs only — a font size, a
layout choice — because those are the differences that can be neither gated nor derived.
Program selection lives in the Program Modules' own gates, and hardware differences live in
Facts. The file is optional: hosts without a degree difference have no Machine File at all.
What makes the User Environment exist is `userEnvironment = true`, not the file's presence.
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
Both halves gate on the `desktop` Capability (derived from `facts.form`), and the system half
is imported wholesale because the third-party modules it pulls in cannot deactivate
themselves.
_Avoid_: DE, WM config, desktop stack.

**System Module**:
A module under `modules/nixos/` or `modules/darwin/`, keyed by platform. It configures the
machine, not the user.
_Avoid_: platform config, host layer.

**System Capability**:
A module under `modules/nixos/optional/` that is inert unless the Host carries its
Capability. It declares no option: the gate is `lib.mkIf host.gates.<capability>`, so a
capability cannot drift from the metadata that decides it. Configuration that every NixOS host needs
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
