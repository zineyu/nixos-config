# Software tree back at the repo root, inventory renamed, and drift reconciled

## Status

Accepted. Re-establishes ADR-0010's `programs/` location and records the
naming/consistency decisions that had drifted from it. Does not supersede
ADR-0016 (programs declare their own capability).

## Date

2026-11-20

## Context

ADR-0010 decided that pure software lives at the repository root in
`programs/`, precisely so that a program is a short, obvious path away from the
root and so that "software" and "system configuration" are separated by a
directory boundary. Since then the tree had been relocated to
`modules/home-manager/programs/` **without a superseding ADR**, while
`README.md`, `CONTEXT.md`, `GLOSSARY.md`, `docs/module-reference.md` and the
CI comments kept describing `programs/`. The result was the worst of both
states:

- Paths grew back to six segments
  (`modules/home-manager/programs/dev/zed/default.nix`) — the exact cost
  ADR-0010 called out.
- `modules/home-manager/` was a wrapper directory containing one child, so it
  expressed no structure of its own.
- Every host module still imported `../../modules/nixos` (or
  `../../modules/darwin`) even though `lib/mkSystem.nix` already broadcasts the
  same tree, contradicting ADR-0014's "hosts stop carrying import lists".
- `hosts/default.nix` (the inventory) shared a filename with each per-host
  `default.nix`.
- `modules/desktop/home/DankMaterialShell/` was capitalised while its siblings
  (`tela-icon-theme/`, `xdg-user-dirs/`) were not.
- A desktop-specific derivation, `lib/niri-config.nix`, sat among generic
  helpers.
- `vars/default.nix` defined `git.*` identity while the git program module
  hardcoded the same values, and `vars.hosts.aliyun-01 = { }` was an empty
  entry.
- `AGENTS.md` was referenced by `README.md` and `flake.nix` but did not exist.

## Decision

1. **Pure software returns to the repository root.** `programs/` holds
   `{shell,terminal,dev,gui,misc}/`. `modules/home-manager/` is deleted.
   `lib/mkSystem.nix` adds `../programs` to `home-manager.sharedModules`, and
   `flake.nix` scans `./programs` and `./modules/desktop` for `package.nix`.
2. **The inventory is `hosts/inventory.nix`.** It is the same mapping, renamed
   to match the term used in `GLOSSARY.md` and to stop colliding with per-host
   `default.nix`. `flake.nix` imports it by name and CI evaluates it by name.
3. **`DankMaterialShell/` becomes `dank-material-shell/`.** Only the source
   asset directory is renamed; the `xdg.configFile` targets keep the
   application's own `DankMaterialShell/…` path.
4. **`lib/niri-config.nix` moves to `modules/desktop/home/niri/build.nix`.**
   A desktop-specific derivation belongs beside its only consumer.
5. **`lib/mkSystem.nix` is the sole broadcaster.** Host modules no longer import
   module trees; they keep only `hardware-configuration.nix` where one exists.
6. **Shared identity is consumed, not copied.** The git program module reads
   `vars.git.name` / `vars.git.email`; the empty `vars.hosts.aliyun-01`
   entry is removed.
7. **`lib/nixpaks-*.nix` stay in `lib/` deliberately.** They require the
   `mkNixPak` module argument and a locally patched `qq`, so they cannot be
   `callPackage … { }` flake packages (the automatic `package.nix` scan would
   fail to evaluate them). They are shared construction helpers consumed by
   `modules/desktop/system/nixpak.nix`, not recipes, and are named accordingly.

## Alternatives Considered

### Keep `modules/home-manager/programs/` and only fix the docs

- Pros: no file moves.
- Cons: keeps the six-segment path and the single-child wrapper that ADR-0010
  exists to prevent; `modules/` keeps containing software.
- Rejected: aligning the code to the written decision is cheaper than
  rewriting three ADRs and a dozen docs to a worse layout.

### Convert `lib/nixpaks-*.nix` into `programs/gui/{qq,wechat}/package.nix`

- Pros: recipes truly co-located with consumers; `.#qq` / `.#wechat` exposed.
- Cons: `flake.nix` builds `customPkgs` with `callPackage file { }`, but these
  files need `mkNixPak` (only provided by a call site that constructs the
  nixpak lib) and the hash-overridden `qq`. Auto-discovery would fail to
  evaluate, breaking `perHost.packages` for every host.
- Rejected: the placement is constrained by evaluation, so it is documented
  rather than forced.

### Rewrite the historical ADRs to the new paths

- Pros: no stale references anywhere.
- Cons: ADRs are decision records; editing them rewrites history.
- Rejected: this ADR records the change instead, and older ADRs are read as
  historical.

## Consequences

- Every documented path now matches the tree: `programs/…`,
  `hosts/inventory.nix`, `modules/desktop/home/niri/build.nix`,
  `modules/desktop/home/dank-material-shell/`.
- Older ADRs (0001, 0002, 0006, 0007, 0009, 0010, 0014, 0015, 0016) still say
  `hosts/default.nix` or describe the option-gated `zine.programs.*` model.
  Those passages are historical; ADR-0016 removed the option model and this ADR
  names the inventory file.
- Adding a program is again: create `programs/<category>/<name>/default.nix`,
  choose its gate. Nothing in `hosts/inventory.nix` changes.
- Adding a host is again: register it in `hosts/inventory.nix`, create
  `hosts/<hostname>/default.nix` with machine facts only.
- `nix flake check` and each host's build must still succeed; the migration is
  path-only apart from the git identity now being sourced from `vars.git`.
