# Self-contained program modules with option-gated configuration

## Status

Accepted (supersedes the layout part of ADR-0007; keeps ADR-0007's per-machine
organization file)

## Date

2026-10-18

## Context

ADR-0007 split user-level configuration into three places per program:

- `modules/home/packages/<category>.nix` declared `zine.programs.<name>.enable`
  and gated installation on it;
- `modules/home/programs/<category>/<name>/default.nix` held configuration;
- `home/<hostname>.nix` imported definition layers and flipped the switches.

This showed four problems:

1. **One program spanned three files across two trees.** Adding `kitty` meant
   editing `packages/terminal.nix`, creating `programs/terminal/kitty/`, and
   editing every machine file that imports the category.
2. **`enable` gated installation but not configuration.** `dolphin` wrote
   `xdg.mimeApps`, `cursor` wrote `home.pointerCursor`, and `gnupg` wrote sops
   and gpg-agent configuration unconditionally. The switch name promised more
   than it delivered, and which configuration leaked depended on which
   directory a machine happened to import.
3. **Machine import granularity carried no meaning.** Category `default.nix`
   files scan their directory, so `tianxuan` (importing all of
   `modules/home/programs`) and `macbook-air-01` (importing selected category
   and program directories) differed only in which ungated configuration
   leaked.
4. **Naming collided.** Root `pkgs/` (derivations) faced
   `modules/home/packages/` (option declarations), and `packages/dev.nix`,
   `packages/dev-tools.nix`, `packages/desktop.nix` versus
   `modules/home/desktop/` described three different things.

## Decision

- **One directory per program owns its option, its installation, and its
  configuration.** `modules/home/programs/<category>/<name>/default.nix`
  declares `zine.programs.<name>.enable` and wraps all of its configuration in
  `lib.mkIf cfg.enable`. Programs without configuration (browsers, DBeaver)
  get the same directory and a three-line module, so one rule covers every
  program.
- **Bare leaf packages become option-gated bundles.**
  `modules/home/bundles/{cli,dev,gui}.nix` declare `zine.bundles.<name>.enable`
  for the tools that have no configuration module.
- **The desktop layer is opt-in by import.**
  `modules/home/desktop/` carries niri, DankMaterialShell, fonts, icon theme,
  XDG user directories and their packages. A machine that wants a Wayland
  desktop imports it; everything else never evaluates it.
- **`modules/home/default.nix` is the single shared layer.** It imports
  `common.nix`, `programs`, `ssh`, `agent-skills`, `bundles` and `services`.
  Machines import one path.
- **Machine files become declarative tables.** `home/<hostname>.nix` imports
  the shared layer (plus the desktop layer where applicable) and then only sets
  `zine.programs.*`, `zine.bundles.*` and `zine.services.*` switches.
- **Shared user modules leave `home/`.** `home/common.nix` becomes
  `modules/home/common.nix`; `home/ssh.nix` becomes
  `modules/home/ssh/default.nix` gated on `zine.programs.ssh.enable`. `home/`
  keeps only per-machine organization files.
- **Machine-specific services become modules.**
  `zine.services.headscale-backup-pull.enable` replaces the systemd units that
  were inlined in `home/tianxuan.nix`.

## Alternatives Considered

### Keep the install/configuration split

- Pros: no change to existing files.
- Cons: the split is the source of problems 1-4 above; a reader cannot find
  everything about one program in one place.
- Rejected: a self-contained directory is the smallest unit that stays
  consistent.

### Gate configuration with `mkIf` but keep `modules/home/packages/`

- Pros: fewer moved files.
- Cons: keeps two parallel trees keyed by the same categories, which is the
  naming and navigation cost without the separation benefit.
- Rejected: options live with their configuration.

### Give every bundle entry its own option

- Pros: uniform granularity.
- Cons: about 60 options for packages that only install, and machine files
  become hundred-line enable lists.
- Rejected: bundles keep a coarse, meaningful granularity.

### Gate the desktop layer behind an option instead of an import

- Pros: machine files stay purely switch-based.
- Cons: the layer imports third-party Home Manager modules (DMS, niri) whose
  assertions stay active even when the layer's own configuration is gated;
  evaluating them on Darwin is not a supported combination.
- Rejected: layer selection is expressed by import, software selection by
  option.

## Consequences

- Adding a program: create `modules/home/programs/<category>/<name>/default.nix`
  with its option, installation and configuration; set the switch in the
  machines that want it. No other file changes.
- Adding a machine: create `hosts/<hostname>/`, register it in
  `hosts/default.nix`, and add `home/<hostname>.nix` with a switch table.
- Every `zine.programs.<name>.enable` now means "install and configure".
- Verified at introduction on both hosts: `home.packages` package sets,
  `home.file` / `xdg.configFile` target paths, and all `programs.*.enable`
  values are identical to the previous layout. Derivation paths changed only
  because `home.packages` entries from moved bundles now merge in a different
  order.
