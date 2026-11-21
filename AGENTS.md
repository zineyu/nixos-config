# AGENTS.md

Operating notes for coding agents working in this repository. Read
`CONTEXT.md`, `GLOSSARY.md` and `docs/module-reference.md` before changing
structure; use the glossary's terms (Host, Tag, Gate, Program Module, Host
Inventory, User Environment).

## Build and check

```bash
nix build .#<host>                       # build a host without activating
nixos-rebuild build --flake .#<host>     # NixOS host
nix build .#darwinConfigurations.<host>.system   # nix-darwin host
nix fmt                                  # format every .nix file
nix flake check --print-build-logs       # lint + eval + deploy checks
just lint-skills                         # skill catalog lint
just deploy <host>                       # deploy-rs to a remote host
```

The dev environment is `devenv.nix` (enter with `direnv allow`). Do not add a
`devShells` output to `flake.nix`.

`just table` prints what each host derives (docker, tailscale, mihomo, nvidia, sshd);
`just programs` prints the Home Manager program modules each host enables. Run them after
changing a gate instead of evaluating hosts one option at a time.

## Layout

| Path | Role |
|---|---|
| `hosts/inventory.nix` | Host Inventory: the single source of host differences (`system`, `platform` (nixos/wsl/darwin), `form` (vm/pc/server), `profile` (work/personal), `facts` (required: `gpu`), `tags`, `userEnvironment`, optional `homeStateVersion`, optional `deploy`). |
| `hosts/<hostname>/default.nix` | Machine facts only: boot loader, kernel, timezone, secret wiring. Imports `hardware-configuration.nix`; never module trees. |
| `hosts/<hostname>/home.nix` | Optional Machine File: `zine.*` knob assignments only. Most hosts have none; `userEnvironment = true` decides whether a User Environment exists. |
| `modules/nixos/` | NixOS system modules: `common/` (baseline), `server/`, `nvidia.nix`, `wsl.nix`. |
| `modules/darwin/` | nix-darwin system modules. |
| `modules/desktop/{system,home}/` | The desktop subsystem, gated on `host.form.pc`. |
| `modules/base/` | Platform-independent Home Manager base layer, wired by `lib/mkSystem.nix`. |
| `modules/mihomo/` | Cross-platform proxy: shared config plus `nixos.nix` / `darwin.nix`. |
| `modules/tailscale/` | Cross-platform tailnet join: `nixos.nix` / `darwin.nix`, both on `host.profile.personal`. |
| `programs/<category>/<name>/` | One self-contained program: `default.nix`, optional `package.nix`, native config files. Categories: `shell`, `terminal`, `dev`, `gui`, `misc`. |
| `lib/` | Generic helpers (`mkSystem`, `scanPaths`, `storeLinks`, `nix-settings`, `host-axes`) and nixpak wrappers (`nixpaks-*`). |
| `vars/` | Shared identity only (`git`, `ssh`). Machine facts belong to the Host Inventory's `facts`. |
| `secrets/` | sops-nix encrypted secrets (see `docs/secrets.md`). |
| `scripts/` | Linters that enforce structure: `lint-skills.py`, `lint-structure.py` (difference axes, ADR-0018). |

Composition is **broadcast-and-gate** (ADR-0014): `lib/mkSystem.nix` imports
every module tree for its platform; each module gates itself on
`host.hasTag "<tag>"`, `host.platform.<platform>`, `host.form.<form>` or
`host.profile.<profile>` (or is ungated baseline). Hosts never carry import
lists or switch tables, and `imports` lists stay unconditional (ADR-0018) so
every host evaluates every module.

Differences use orthogonal axes (ADR-0018 / ADR-0019): **platform** (nixos/wsl/
darwin), **form** (vm/pc/server), **profile** (work/personal) → inventory;
**facts** (hardware: GPU, displays) → inventory's `facts`; **labels** (what the
machine *is*) → `tags`, read with `host.hasTag "<tag>"`; **degree** (a
value with a default) → a `zine.*` knob assigned by a Machine File.
`scripts/lint-structure.py` enforces the rules (R1–R5, `just lint-structure`).

## Rules for changes

Before writing a gate or changing how a host differs, read the **Tag**, **Gate** and
**Axis** entries in `GLOSSARY.md`: they define what each metadata field means.

- **New program**: create `programs/<category>/<name>/default.nix` and test the
  prerequisite it needs — `lib.mkIf (host.hasTag "gui")`, `lib.mkIf host.form.pc`,
  `lib.mkIf host.platform.linux` — or write `config = { … };` if it belongs to
  the baseline. Do not register it in the inventory. A per-device parameter
  becomes a `zine.<program>.<name>` option **with a default** in that module;
  never a Machine File writing upstream option paths.
- **New device difference**: decide the axis first (ADR-0018 / ADR-0019).
  Platform/form/profile → their dedicated fields; a label → `tags`, tested with
  `host.hasTag "<tag>"`; hardware → `facts`; a value with a default → a
  knob overridden from `hosts/<hostname>/home.nix`. Never branch on `host.name`.
- **New custom package**: put `package.nix` in the consuming program (or system
  module) directory; the flake exposes it as `.#<directory-name>`.
- **New host**: add an entry to `hosts/inventory.nix` with `platform`, `form`,
  `profile` and `facts` (`gpu` is required), then create
  `hosts/<hostname>/default.nix` with machine wiring only. Set
  `userEnvironment = true` when it needs a User Environment; add
  `hosts/<hostname>/home.nix` only if it also has a degree difference.
- **New Tag**: add the label to the host's `tags` list in
  `hosts/inventory.nix` and let the module test it with
  `lib.mkIf (host.hasTag "<tag>")`. A tag describes what the host *is*; it is
  not a switch — platform, form and profile are separate axes; GPU is a fact.
  There is no tag vocabulary file, so nothing rejects a typo: a tag no module
  reads is a label nobody recognises, and nothing happens. Keep `imports`
  unconditional.
- **New system capability**: a module that only some hosts need goes in the tree
  its precondition names — `modules/<name>/` when both platforms share it,
  `modules/nixos/` or `modules/darwin/` when one does — and tests that
  precondition in its body. `modules/nixos/common/` holds only what every NixOS
  host needs.
- Keep native config files next to the module that installs them.
- Update `docs/module-reference.md` when you add or move a module.

## Style

- `nixfmt` formatting, `deadnix` and `statix` clean. CI runs all three.
- Match the existing comment style; Chinese comments are fine and common.
- Prefer editing the smallest surface; do not restructure unrelated trees.

## Security

- Secrets only through `sops-nix` and `secrets/*.yaml`. Never commit plaintext
  tokens, keys or passwords, and never place secrets in the Nix store.
- `{{NAME_…}}` placeholders are injected at runtime; use them verbatim.
