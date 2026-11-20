# Broadcast-and-gate: modules gate themselves on typed host metadata

## Status

Accepted (supersedes the "Add capability flags to the Host Inventory" alternative
rejected by ADR-0013; refines ADR-0006's inventory and ADR-0009's opt-in pattern)

## Date

2026-11-20

## Context

ADR-0013 split `modules/nixos/` into an unconditional baseline (`common/`) and
pluggable capabilities (`optional/`), and made each capability declare
`zine.system.<name>.enable` so a Host could select it from
`configuration.nix` instead of editing an import list. That was an improvement,
but it only moved the decision, it did not remove it: every host still carries a
hand-written switch table, and every tree that could not express itself as an
option (`server/`, `desktop/system/`, `modules/darwin/`, `modules/mihomo/`)
still required a hand-written import list.

The consequence is visible in the WSL host. Nothing in the repository knows that
`work-hp-laptop` cannot run `boot.kernelPackages`, must not join the Headscale
tailnet, and should not pull the Wayland desktop stack. That knowledge lives in
the head of whoever added the host, encoded as *the absence of lines*, in four
different files. ADR-0013 already used that exact failure as its justification
for `optional/`, which is the tell: the information needed to decide was host
metadata, but it was being expressed as configuration.

ADR-0013 rejected putting capability flags in the inventory because the
inventory "would become a second, unrelated configuration surface". The premise
was that the inventory describes build metadata and therefore must not describe
software. The experience since then says the opposite: for capabilities that
follow from *what kind of machine this is*, metadata is the only honest place to
put the decision, and a per-host switch table is the duplicate.

## Decision

Adopt **broadcast-and-gate**: every module tree is imported by every host, and
each module decides for itself whether to activate, based on typed host metadata.

1. **The inventory becomes typed host metadata.** `hosts/default.nix` entries
   carry `tags` (machine form, session and system capabilities) alongside
   `system`, `kind`, `homeStateVersion` and `deploy`. The tag vocabulary lives in
   `lib/host-tags.nix` and is typed as
   `types.listOf (types.enum knownTags)` — an unknown tag fails evaluation
   instead of silently doing nothing. (The `programs` list this ADR originally
   introduced was removed by ADR-0016.)

2. **Metadata reaches every module as a specialArg.** `lib/mkSystem.nix`
   normalises the inventory entry and injects it as `host` into both NixOS /
   nix-darwin `specialArgs` and Home Manager `extraSpecialArgs`. `zine.host` is a
   read-only projection of the same data, for `nix eval` auditing and for
   cross-tag assertions; it is not a second source of truth.

3. **Composition roots broadcast, tree entries gate.** `lib/mkSystem.nix`
   imports `modules/nixos` or `modules/darwin` unconditionally. Each subtree's
   `default.nix` reads `host.gates` and decides:

   | Tree | Gate |
   |---|---|
   | `modules/nixos/common` | always (the baseline) |
   | `modules/nixos/optional` | per capability, option default from the tag |
   | `modules/nixos/server` | `server` |
   | `modules/desktop/system` | `desktop` |
   | `modules/nixos/wsl` | `wsl` |
   | `modules/nixos/nvidia` | `nvidia` |
   | `modules/darwin/sops.nix` | always (Darwin secret base) |
   | `modules/darwin/{tailscale,remote-login}` | `tailscale` / `remote-login` |
   | `modules/mihomo/{nixos,darwin}.nix` | `mihomo` |
   | `modules/desktop/home` | `desktop` |
   | `programs/` | each Program Module declares the capability it needs (ADR-0016) |
   | `modules/base/services/*` | per service, option default from the tag |

4. **Gates read the specialArg, never `config`.** `imports` is evaluated during
   module collection, before `config` exists; reading `config.zine.host` there
   is an infinite recursion. Gating therefore uses `host.gates.<tag>` (a boolean
   projection of `host.tags`, total over the vocabulary, so a misspelled tag is
   an evaluation error rather than a silent `false`), and the `zine.host` option
   tree exists for validation, introspection and assertions.

5. **Hosts stop carrying decisions.** `configuration.nix` files keep machine
   facts (boot loader, kernel, locale, hardware bus ids, deployment workarounds)
   and service parameters (sops wiring, secrets). They no longer contain
   `zine.system.*` / `zine.programs.*` assignments or import lists of module
   trees. `hosts/<hostname>/home.nix` keeps genuine machine-local overrides (a
   font size, a single package), and whether it exists is declared by the
   inventory's `userEnvironment` flag (ADR-0015).

6. **No option, no escape hatch.** The capability modules declare no
   `zine.system.*` option at all: the gate is
   `lib.mkIf host.gates.<tag>`. A capability therefore cannot drift
   from the metadata that decides it. A host that genuinely needs to deviate
   changes its Tags, or the capability becomes a first-class module of its own —
   there is deliberately no per-host switch to fall back on. The same applies to
   user-level services in `modules/base/services/`.

## Alternatives Considered

### Keep host-written switch tables (status quo ante)

- Pros: the switch table is a readable inventory of what a machine runs.
- Cons: it duplicates metadata for every kind-determined capability; the WSL
  kernel/tailnet problem is solved by remembering, not by construction; adding a
  machine feature means editing 4 files.
- Rejected: the information is a property of the machine, not a choice.

### Metadata only for system capabilities, switches for programs (hybrid)

- Pros: smallest diff; keeps the program list explicit and greppable.
- Cons: two composition mechanisms in one repository, and the program list is
  itself host metadata — it was the largest hand-maintained table in the repo.
- Rejected: the whole point is one mechanism, one place to look.

### `profiles` as an explicit layer between metadata and modules

- Pros: named bundles (`desktop-workstation`, `cloud-server`) compose well and
  keep the tag vocabulary small.
- Cons: a second indirection; with 4 hosts the tag set *is* the profile, and
  profiles would need their own gating rules.
- Rejected for now: revisit if the host count or role diversity grows.

## Consequences

- Adding a host: one inventory entry. No import lists, no switch tables, no
  `flake.nix` edits.
- Adding a capability: declare the tag in `modules/host-metadata.nix`, gate the
  module on it, tag the hosts that have it. There is no option to declare.
- Removing an option is part of the change: `zine.system.*` and
  `zine.services.*` no longer exist, so nothing can enable a capability except
  the Host Metadata that describes the machine. `zine.programs.<name>.enable`
  stays, because it is the Program Module's own interface and is driven by the
  inventory's `programs` list rather than by a hand-written switch.
- Debuggability moves from "read one host file" to "read the gates". Mitigations:
  `nix eval .#<host>.config.zine.host` prints the resolved metadata, and
  `modules/host-metadata.nix` carries assertions for illegal tag combinations
  (`desktop` + `server`, `remote-login` outside Darwin, …).
- Evaluation cost grows: every host evaluates every module's options. With ~90
  program modules already broadcast this is negligible; option definitions are
  cheap, and `mkIf` keeps unevaluated branches out of the derivation.
- A misspelled tag fails the enum check, and a misspelled program name fails a
  dedicated assertion (program names are directory names, so there is no option
  for the module system to reject them on its own). Both are earlier and louder
  than the old silent omission.
- Platform still splits structurally: `modules/darwin` is broadcast only to
  Darwin hosts, because NixOS and nix-darwin are different module systems.
  Cross-platform modules follow `modules/mihomo/`'s precedent — shared data plus
  a `nixos.nix` / `darwin.nix` pair, mounted by each platform tree.
- Verified at introduction: each host's `nix build` must reproduce the previous
  closure. The migration is behaviour-preserving by construction (every tag was
  derived from the switch that previously existed), but it is worth comparing
  drvPaths per host before deleting the old files from history.
