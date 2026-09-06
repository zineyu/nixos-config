# Unified multi-platform host inventory drives outputs and deploy

## Status

Accepted (supersedes ADR-0001 in scope; extends ADR-0002)

## Date

2026-07-17

## Context

ADR-0001 committed this repository to a single flake build path, at a time when
only NixOS hosts existed. Since then the repository gained a nix-darwin host
(`macbook-air-01`) and deploy-rs based remote deployment (`aliyun-01`), and the
host metadata had become scattered across three places:

- `hosts/default.nix` mapped `hostname -> system`;
- `vars/default.nix` repeated each `hostname` alongside hardware and WireGuard data;
- `flake.nix` hardcoded the deploy-rs node for `aliyun-01`, including its
  activation architecture.

Adding a host required editing all three locations, and nothing (beyond the
WireGuard assertions) checked that they stayed in sync. Home Manager's
`home.stateVersion` was also a single global constant in
`modules/home/common.nix`, which is wrong for hosts installed at different
times and for future Darwin-only hosts.

## Decision

Upgrade `hosts/default.nix` from a `hostname -> system` mapping to a
structured inventory. The attr key is the hostname; each entry declares:

```nix
{
  system = "x86_64-linux";        # build platform
  kind = "nixos";                 # nixos | darwin
  homeStateVersion = "26.05";     # optional, default "26.05"
  deploy = {                      # optional, deploy-rs metadata
    enable = true;
    hostname = "aliyun-01";
    sshUser = "root";
  };
}
```

Consequences of the single source of truth:

- `flake.nix` filters the inventory by `kind` to produce
  `nixosConfigurations` / `darwinConfigurations`, and generates `deploy.nodes`
  from entries with `deploy.enable = true`. No host metadata lives in
  `flake.nix` anymore.
- `lib/mkSystem.nix` receives the full host attrset, shares one Home Manager
  integration module between NixOS and nix-darwin, and injects
  `homeStateVersion` into Home Manager `extraSpecialArgs`.
- `modules/home/common.nix` sets `home.stateVersion` from the injected value;
  it is a per-host compatibility pin and never floats with nixpkgs updates.
- `vars/default.nix` no longer stores per-host `hostname` fields; host modules
  use the injected `hostname` specialArg for `networking.hostName`.
- The inventory stays a plain attrset. It is not a module system and does not
  try to express feature selection; profiles/options (if introduced later) are
  a separate layer chosen by host modules.

This supersedes ADR-0001's "NixOS flake only" scope: the repository is now a
multi-platform (NixOS + nix-darwin) flake with a single build path and no
standalone Home Manager outputs. ADR-0002's "explicit registry" decision is
retained; only the registry's value shape changed.

## Alternatives Considered

### Keep `hostname -> system` and hardcoded deploy nodes

- Pros: zero churn.
- Cons: metadata drift across three files; adding a remote host requires
  editing `flake.nix`; deploy activation architecture hardcoded.
- Rejected: the duplication already caused stale data and extra toil.

### Full profile/feature framework (per-host module lists in the inventory)

- Pros: maximum flexibility; feature selection visible in one file.
- Cons: turns the inventory into a DSL; importing modules by path from a data
  file is harder to read than ordinary module `imports`.
- Rejected for now: with three hosts, host modules importing shared modules
  directly remains clearer. Revisit if host count or role diversity grows.

## Consequences

- Adding a host: create `hosts/<hostname>/default.nix`, register one entry in
  `hosts/default.nix`, and (for remote hosts) add a `deploy` block there plus
  sops keys. No `flake.nix` edits.
- `vars/` keeps only genuine cross-host domain data (git identity, WireGuard
  topology, per-host hardware/WireGuard facts).
- Verified at introduction: all three system toplevel drvPaths were
  bit-identical before and after the migration, i.e. zero behavioral change.
