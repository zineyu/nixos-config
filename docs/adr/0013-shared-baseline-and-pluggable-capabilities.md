# Shared NixOS baseline versus pluggable system capabilities

## Status

Accepted (refines ADR-0006's Host Inventory and ADR-0009's opt-in pattern)

## Date

2026-11-19

## Context

`modules/nixos/common/` described itself as the configuration all hosts share,
but `scanPaths` made that literal: Docker, sshd, Tailscale and
`boot.kernelPackages = linuxPackages_latest` reached every NixOS host whether
or not that host wanted them.

Adding a NixOS-WSL host exposed the cost. A WSL machine uses the
Windows-provided kernel, does not necessarily want an inbound sshd, and joining
the Headscale tailnet is a decision rather than a baseline. Because the modules
were unconditional, there were only two ways to add the machine:

- import `modules/nixos` and inherit capabilities it cannot or should not use
  (Tailscale would demand a sops preauth key; the kernel option contradicts
  WSL), or
- stop importing the tree and lose `users.users.zine`, the shared Nix daemon
  settings, the locale and the base packages along with it.

Neither is acceptable: the baseline is what every NixOS host genuinely needs,
and the rest are capabilities a host may plug in.

## Decision

- **`modules/nixos/common/` is the baseline.** It contains only configuration
  every NixOS host must have: Nix daemon settings, locale, the `zine` user with
  its shell and authorized key, and the base package list. `modules/nixos`
  imports it unconditionally.
- **`modules/nixos/optional/` holds pluggable capabilities.** Each file
  declares `zine.system.<name>.enable` with `lib.mkEnableOption` (default
  `false`) and wraps all of its configuration in `lib.mkIf cfg.enable`.
  `modules/nixos/default.nix` imports the directory, so a Host selects
  capabilities with option assignments in its `configuration.nix` instead of
  editing an import list.
- **The Docker group belongs to the Docker capability.** `docker` is created by
  `virtualisation.docker`, so `users.users.zine.extraGroups` adds it only when
  `zine.system.docker.enable` is on. A host without Docker would otherwise
  reference a group that does not exist.
- **Kernel and bootloader stay host-specific.** `boot.kernelPackages` moves to
  `hosts/<hostname>/` next to the boot loader: it is a property of the machine,
  not shared baseline and not a feature toggle. WSL omits it.
- **Existing hosts keep their behavior.** `tianxuan` and `aliyun-01` explicitly
  enable the Docker, sshd and Tailscale capabilities they previously inherited
  from `common/`.

## Alternatives Considered

### Opt in by explicit imports

- Pros: mirrors the Desktop Layer; unused modules are never evaluated.
- Cons: every host accumulates import paths, and the selection is invisible in
  the host's option table. The Desktop Layer uses imports because it pulls
  third-party modules whose assertions remain active; these capabilities are
  first-party NixOS options, so an option is sufficient.
- Rejected: `zine.system.*` keeps machine configuration declarative.

### Keep everything in `common/` and override per host

- Pros: no file moves.
- Cons: WSL still evaluates the Tailscale sops secret and the Linux kernel
  packages, and overrides use `mkForce`, which hides intent instead of
  expressing it.
- Rejected: a capability that is off should evaluate nothing.

### Add capability flags to the Host Inventory

- Pros: one place for host metadata.
- Cons: the inventory describes build metadata (`system`, `kind`,
  `homeStateVersion`, `deploy`), not software selection; it would become a
  second, unrelated configuration surface.
- Rejected: capabilities live where their configuration lives.

## Consequences

- Adding a capability: create one file in `modules/nixos/optional/` with its
  option and gated configuration; hosts enable it.
- Adding a host: import `modules/nixos` for the baseline, then set the
  `zine.system.*` switches it wants. A WSL host simply omits the kernel,
  Docker, sshd and Tailscale.
- `common/` answers "what does every NixOS host have?"; `optional/` answers
  "what can a host add?".
- `nix flake check` and `nix build .#<host>` verify that every registered host
  still evaluates with its chosen set of capabilities.
