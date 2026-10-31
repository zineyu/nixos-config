# nixpkgs tracks the nixos-unstable channel revision

## Status

Accepted

## Date

2026-11-01

## Context

`flake.nix` pins `github:NixOS/nixpkgs/nixos-unstable`, i.e. a **branch**, so
`nix flake update` locks the branch tip. The tip runs ahead of what Hydra has
finished building into `cache.nixos.org`: a package bumped in that window has no
substitute yet, and anything depending on it is compiled from source. On the
4-core hosted runners a single Rust package from the closure (`codex`) costs
~50 minutes, so the daily `build.yml` run spent 1.5-2 hours compiling and then
died from OOM/disk exhaustion (`Process completed with exit code 143`,
"hosted runner lost communication") — see runs of 2026-10-24 .. 2026-10-31.

The channel itself publishes the revision it was built from
(`https://channels.nixos.org/nixos-unstable/git-revision`), and that revision
lags the branch tip by only hours to a couple of days.

## Decision

Pin nixpkgs to the channel revision instead of the branch tip, in one place:
`scripts/update-flake.sh` runs `nix flake update` and then

```
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<channel-rev>
```

Both `just update` and `.github/workflows/update.yml` call that script, so local
and CI updates follow the same rule. Inputs declaring
`inputs.nixpkgs.follows = "nixpkgs"` (home-manager, nix-darwin, sops-nix,
llm-agents.nix, ...) resolve to the pinned revision; the input URL stays
`nixos-unstable`, so only `flake.lock` changes.

## Consequences

- Everything nixpkgs ships can be substituted from `cache.nixos.org` by both CI
  and local rebuilds, instead of being compiled from source.
- Other inputs still track their own branches, and the channel revision can be
  a couple of days older than them, so `nix flake check` (`update.yml`) and the
  host builds (`build.yml`) remain the compatibility gate — `update.yml` only
  commits the lock when the check passes.
- The decision does not cover cache misses that do not come from nixpkgs:
  `llm-agents.nix` publishes prebuilt binaries on `cache.numtide.com`, which
  therefore has to be configured as a substituter in CI as well, and packages a
  third-party flake pins against *its own* nixpkgs (nixvim's plugin set) are
  still built from source.
- Upstream nixpkgs fixes arrive hours-to-days later than on the branch tip. To
  take one immediately: `nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable`.
