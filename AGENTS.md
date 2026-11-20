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

## Layout

| Path | Role |
|---|---|
| `hosts/inventory.nix` | Host Inventory: the single source of host differences (`system`, `kind`, `tags`, `userEnvironment`, optional `homeStateVersion`, optional `deploy`). |
| `hosts/<hostname>/default.nix` | Machine facts only: boot loader, kernel, timezone, secret wiring. Imports `hardware-configuration.nix`; never module trees. |
| `hosts/<hostname>/home.nix` | Optional User Environment overrides. Its existence is declared by `userEnvironment = true`, not inferred. |
| `modules/nixos/` | NixOS system modules: `common/` (baseline), `optional/` (per Tag), `server/`. |
| `modules/darwin/` | nix-darwin system modules. |
| `modules/desktop/{system,home}/` | The desktop subsystem, gated on `desktop`. |
| `modules/base/` | Platform-independent Home Manager base layer, wired by `lib/mkSystem.nix`. |
| `modules/mihomo/` | Cross-platform proxy: shared config plus `nixos.nix` / `darwin.nix`. |
| `programs/<category>/<name>/` | One self-contained program: `default.nix`, optional `package.nix`, native config files. Categories: `shell`, `terminal`, `dev`, `gui`, `misc`. |
| `lib/` | Generic helpers (`mkSystem`, `scanPaths`, `storeLinks`, `nix-settings`, `host-tags`) and nixpak wrappers (`nixpaks-*`). |
| `vars/` | Shared identity (`git`, `ssh`) and per-host machine values. |
| `secrets/` | sops-nix encrypted secrets (see `docs/secrets.md`). |

Composition is **broadcast-and-gate** (ADR-0014): `lib/mkSystem.nix` imports
every module tree for its platform; each module gates itself on
`host.gates.<tag>` (or is ungated baseline). Hosts never carry import lists or
switch tables.

## Rules for changes

- **New program**: create `programs/<category>/<name>/default.nix` and declare
  the capability it needs — `lib.mkIf host.gates.gui`, `lib.mkIf
  host.gates.desktop`, `lib.mkIf (host.kind == "nixos")` — or write
  `config = { … };` if it belongs to the baseline. Do not register it in the
  inventory.
- **New custom package**: put `package.nix` in the consuming program (or system
  module) directory; the flake exposes it as `.#<directory-name>`.
- **New host**: add an entry to `hosts/inventory.nix`, then create
  `hosts/<hostname>/default.nix` with machine facts only. Add `home.nix` and
  `userEnvironment = true` only when the host needs a User Environment.
- **New Tag**: add it to `lib/host-tags.nix` (the single vocabulary source) and,
  if it constrains combinations, add an assertion in
  `modules/host-metadata.nix`. Gate with `host.gates.<tag>`; never
  `lib.elem "…" host.tags` (typos then fail silently).
- **New system capability**: `modules/nixos/optional/` for Tag-gated
  capabilities; `modules/nixos/common/` only for what every NixOS host needs.
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
