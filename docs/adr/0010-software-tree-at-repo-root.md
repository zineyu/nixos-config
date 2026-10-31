# Software tree at the repository root

## Status

Accepted (supersedes the layout decisions of ADR-0009; keeps ADR-0009's
"one directory per program, installation and configuration gated by one option"
principle)

## Date

2026-11-01

## Context

ADR-0009 made every program a self-contained directory, but kept the trees where
they had historically grown. That left five problems:

1. **Pure software lived under `modules/`.** `modules/home/programs/` mixed
   "what software the user gets" with "how the system is configured", so five
   path segments (`modules/home/programs/dev/zed/default.nix`) separated a
   program from the repository root, and the two trees were edited for unrelated
   reasons.
2. **Granularity was inconsistent and hid platform assumptions.**
   `modules/home/bundles/{cli,dev,gui}.nix` grouped ~56 packages behind three
   switches, so a machine could not take one tool without the rest. The `dev`
   bundle installed `ccache`, whose `nativeCheckInputs` unconditionally pulls
   the Linux-only `elfutils`; enabling the bundle on `macbook-air-01`
   (aarch64-darwin) therefore broke *evaluation* of the whole system. The
   upstream fix existed only in nixpkgs master, not in the pinned
   `nixos-unstable`, so the bundle boundary - not a package bug - was the
   problem.
3. **One subsystem spanned two platform-keyed trees.** `modules/home/desktop/`
   (user side) and `modules/nixos/desktop/` (system side) described one
   desktop, forcing a reader to know the platform mapping to find niri, DMS or
   the input method.
4. **Machine files imported layers.** `home/<hostname>.nix` had to import
   `modules/home` (and sometimes the desktop layer) before flipping switches, so
   the import list - not the switch table - decided what a machine could enable.
5. **Custom package recipes were detached and hardcoded.**
   `pkgs/<name>.nix` faced the module that consumed it, and `flake.nix` listed
   all six packages by hand, so adding a recipe meant editing three places.

## Decision

- **Pure software moves to the repository root: `programs/`.** Categories are by
  kind of software (`shell/`, `terminal/`, `dev/`, `gui/`, `misc/`), never by
  platform. Each `programs/<category>/<name>/` is one program: `default.nix`
  declares `zine.programs.<name>.enable` and gates installation *and*
  configuration on it. Leaves that need no configuration are the same
  three-line module, so one rule covers every program.
- **Bundles are deleted.** `zine.bundles.*` disappears; machine files list the
  programs they want. A machine can now express "all CLI tools except `ccache`",
  which is exactly what a Darwin machine needs.
- **`modules/` keeps only system-side configuration, grouped by platform and by
  subsystem:**
  - `modules/nixos/` - NixOS common layer and server modules;
  - `modules/darwin/` - nix-darwin modules;
  - `modules/desktop/home/` - user-level desktop layer (niri,
    DankMaterialShell, fonts, icon theme, XDG user dirs);
  - `modules/desktop/system/` - system-level desktop layer (greetd/portal,
    audio, graphics, input method, nixpak overlay, Steam);
  - `modules/base/` - platform-independent Home Manager base (state version,
    agent skills, user services).
- **`lib/mkSystem.nix` wires the platform-independent user environment.**
  `modules/base` and `programs` are added to `home-manager.sharedModules`, so a
  machine file only imports the layers that are genuinely machine-specific
  (`modules/desktop/home` for the Wayland desktop) and otherwise is a switch
  table.
- **Package recipes live next to their consumers as `package.nix`.** The flake
  discovers them by scanning `programs/` and `modules/desktop/`, and the
  attribute name is the containing directory name, which is also the
  `nix-update --flake <attr>` name. Self-maintained update scripts sit in the
  same directory (`update.sh`) and locate their recipe through the git index by
  directory name, since the script itself runs from the Nix store.
- **`pkgs/` is deleted.**

## Alternatives Considered

### Keep bundles, just stop enabling the `dev` bundle on Darwin

- Pros: smallest possible change; fixes the `ccache` evaluation failure.
- Cons: keeps a coarse switch that forces unrelated tools together, which is
  what the user asked to remove; the next Linux-only package in a bundle breaks
  Darwin again.
- Rejected: the bundle boundary is the defect, not its membership.

### Keep `modules/home/programs/` and only rename the category directories

- Pros: fewer moved files.
- Cons: `modules/` still contains software, and adding a program still means
  editing a tree whose other content is system configuration.
- Rejected: the tree boundary should follow "software vs. system configuration",
  the distinction the repository already uses everywhere else.

### Group the desktop layer by platform (`modules/desktop/{home,nixos}`)

- Pros: one aggregator per module type.
- Cons: reintroduces the platform split problem 3 for the desktop subsystem,
  which is the one subsystem where user and system halves are edited together.
- Rejected: `home/` and `system/` name the *module type* (Home Manager vs.
  NixOS), and both live under the same subsystem directory.

### Scan the whole repository for `package.nix`

- Pros: recipes could sit anywhere.
- Cons: recursion over `.git`, `.jj`, `.devenv` and `result` at evaluation time,
  and no explicit statement of where recipes belong.
- Rejected: two scan roots (`programs/`, `modules/desktop/`) are cheap and
  explicit.

## Consequences

- Adding a program: create `programs/<category>/<name>/default.nix`, flip
  `zine.programs.<name>.enable` in the machine files that want it. Nothing else.
- Adding a custom package: put `package.nix` in the program directory that
  consumes it; the flake exposes `.#<dirname>` automatically. Update scripts go
  beside it.
- Adding a machine: create `hosts/<hostname>/`, register it in
  `hosts/default.nix`, add `home/<hostname>.nix`. The base layer and the program
  options come in automatically.
- Machine files grow to one line per program (30-60 lines). This is the intended
  cost of per-software granularity.
- Verified at introduction: for all three hosts the `home.packages`,
  `home.file`, `xdg.configFile` and `environment.systemPackages` sets are
  unchanged, and all three `drvPath`s are byte-identical to the pre-move
  configuration. The only intended delta is that `macbook-air-01` no longer
  installs `ccache`, which removes the Darwin evaluation failure without any
  overlay.
- CI's `update-pkgs` workflow filters and commits `*package.nix` paths instead
  of `pkgs/`.
