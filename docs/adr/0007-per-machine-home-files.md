# Per-machine Home Manager files with opt-in program options

## Status

Accepted (updates ADR-0004; builds on ADR-0006)

## Date

2026-07-17

## Context

ADR-0004 collapsed user configuration into a single shared `modules/home/`
tree that every host imported wholesale. As the repository grew to multiple
platforms (NixOS desktop, NixOS server, nix-darwin), this showed three
problems:

1. **No per-machine choice.** Importing `modules/home` activated everything:
   the full development toolchain, coding agents, and every configured program.
   The only platform mechanism was the `linuxOnly` helper, an all-or-nothing
   gate that could not express "this Mac wants the base shell but not the GUI
   agents" or "a future minimal Linux host wants none of the desktop".
2. **Wiring lived in host modules.** Each `hosts/<hostname>/default.nix`
   contained `home-manager.users.zine = import ../../modules/home`, mixing the
   Home Manager declaration into system-level host files.
3. **Indirection without control.** `linuxOnly` (and its `hostIsLinux`
   specialArg) existed solely because platform differences had no other place
   to live.

## Decision

User-level configuration is reorganized around explicit per-machine
organization files:

- **Shared definitions move to top-level `home/`** (`packages/`, `programs/`,
  `shell/`, `desktop/`, `common.nix`, `ssh.nix`). Shared modules define
  software but never enable it by default.
- **`home/packages/<category>.nix` declares `zine.programs.<name>.enable`
  options** (default `false`) and gates the corresponding
  `programs.<name>.enable` / package installations on them. Configuration
  stays in `home/programs/<category>/<name>/` and is inert unless the program
  is enabled.
- **Bare leaf packages with no configuration** (CLI tools, compiler toolchain,
  coding agents, GUI extras, desktop fonts) live in opt-in bundle files
  (`tools.nix`, `dev-tools.nix`, `gui-extras.nix`, `desktop.nix`) that machine
  files import explicitly.
- **Each machine gets exactly one organization file `home/<hostname>.nix`**,
  which is fully explicit: it lists the imports it wants and the
  `zine.programs.*` switches it enables.
- **`lib/mkSystem.nix` wires `home-manager.users.zine` from
  `home/<hostname>.nix` when the file exists** (convention over per-host
  wiring). A host without a home file (e.g. `aliyun-01`) gets no user
  environment.
- **The `linuxOnly` helper and `hostIsLinux` specialArg are removed.**
  Machines explicitly select modules and bundles; package derivations remain the
  authority on whether software supports the evaluated platform.

## Alternatives Considered

### Keep preset bundles (`home/base.nix`, `home/darwin.nix`)

- Pros: machine files stay one line for common cases.
- Cons: presets are just hidden defaults; changing a preset silently changes
  every machine that imports it, which is exactly the coupling we are
  removing.
- Rejected: machine files are fully explicit instead.

### Per-program `mkEnableOption` for every bare package

- Pros: uniform granularity.
- Cons: ~60 extra options for zero-configuration leaf packages; machine files
  would degenerate into 100-line enable lists that must be touched whenever a
  CLI tool is added.
- Rejected: options only exist for programs that have configuration; bare
  packages are grouped into opt-in bundles.

### Keep `linuxOnly` for GUI/desktop subtrees

- Pros: category aggregators can hide unsupported packages from some platforms.
- Cons: this duplicates package platform metadata and turns repository structure
  into a second compatibility authority that can drift from package definitions.
- Rejected: machines select desired software explicitly, while each package
  determines and reports its own platform support.

## Consequences

- Adding a program: declare its option in `home/packages/<category>.nix`
  (gating install), add config in `home/programs/<category>/<name>/`, then
  enable it in the `home/<hostname>.nix` files that want it.
- Adding a machine: create `hosts/<hostname>/` (system) and optionally
  `home/<hostname>.nix` (user environment). No other file needs editing.
- Behavior was preserved at introduction: `home.packages` sets, all
  `programs.*.enable` values, and xdg/systemd/sessionVariable attribute sets
  were verified identical to the previous layout on both `tianxuan` and
  `macbook-air-01`. The only intentional delta is the kitty out-of-store
  symlink target path following the `modules/home` → `home` move.
