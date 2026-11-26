# One directory per host: fold the Machine File into hosts/<hostname>/

## Status

Accepted (supersedes ADR-0007's location for the Machine File and its
existence-as-marker convention; applies ADR-0014's metadata rule to the user
environment)

## Date

2026-11-20

## Context

ADR-0007 gave each machine a single organization file at `home/<hostname>.nix`
and made `lib/mkSystem.nix` wire `home-manager.users.zine` when that file exists.
That was written when a Machine File carried an import list and a switch table,
so a separate root directory was worth its weight.

ADR-0014 removed both of those jobs: capabilities gate themselves on Tags, and
software selection moved to the Host Inventory's `programs` list. What remained
in `home/` afterwards was:

| File | Content |
|---|---|
| `home/tianxuan.nix` | `programs.kitty.font.size = 12.0;` |
| `home/macbook-air-01.nix` | `home.packages = [ pkgs.mihomo ];` |
| `home/work-hp-laptop.nix` | nothing |

Three files, two lines of configuration, and one file whose only purpose was to
exist. Meanwhile answering "what is different about this machine?" required
reading three places at two different depths: `hosts/default.nix` (tags and
programs), `hosts/<hostname>/` (system facts) and `home/<hostname>.nix` (user
overrides). That is the same fragmentation ADR-0006 fixed for host metadata,
left in place on a second axis.

The `hosts/<hostname>/default.nix` + `configuration.nix` split had decayed the
same way: it existed so that `nixos-generate-config` output and kernel/boot
settings had a home separate from the host module entry, and that entry no
longer assembles anything.

## Decision

**A machine is one directory.** `hosts/<hostname>/` holds everything about that
machine:

| File | Role |
|---|---|
| `default.nix` | System facts: boot loader, kernel, locale, hostname, secret wiring, deployment workarounds |
| `home.nix` | User Environment overrides (optional) |
| `hardware-configuration.nix` | `nixos-generate-config` output |

- **The Machine File moves from `home/<hostname>.nix` to `hosts/<hostname>/home.nix`.**
  It stays a Home Manager module; `lib/mkSystem.nix` imports it. Platform and
  secret wiring are unaffected.
- **`default.nix` and `configuration.nix` merge into `default.nix`.** There is no
  longer an import list to assemble, so the two-file convention buys nothing.
- **Existence is declared, not inferred.** The Host Inventory gains
  `userEnvironment = true`. `lib/mkSystem.nix` gates
  `home-manager.users.zine` on that flag instead of on
  `builtins.pathExists home/<hostname>.nix`. `modules/host-metadata.nix`
  asserts that the flag implies `hosts/<hostname>/home.nix` exists, so a missing
  file is a named error rather than a silently absent user environment.
- **`aliyun-01` still has no User Environment.** It simply omits the flag and
  has no `home.nix`.

## Alternatives Considered

### Keep `home/` at the repository root

- Pros: zero churn; the directory name states "this is Home Manager code".
- Cons: three read locations for one machine; the empty marker file stays; the
  directory exists only to hold two lines and a convention.
- Rejected: the namespace boundary is already expressed by the module system,
  not by directory placement.

### Put user overrides in the inventory as data

- Pros: literally one place per machine.
- Cons: `programs.kitty.font.size` is an option path, not a value to be stored in
  a metadata attrset; this is the DSL outcome ADR-0006 rejected.
- Rejected: a Machine File is code, and code belongs next to the module it
  configures.

### Keep `default.nix` + `configuration.nix`

- Pros: familiar NixOS layout; `nixos-generate-config` users expect it.
- Cons: the only content that justified it was the import list, which ADR-0014
  removed.
- Rejected: one host, one file, unless the host genuinely needs to split.

### Model the user environment as another Tag

- Pros: one mechanism for everything.
- Cons: "has a user environment" is not a capability a module gates on; it
  decides whether an entire option tree is instantiated. It also needs a
  username, which is inventory data, not a label.
- Rejected: `userEnvironment` stays a distinct boolean field.

## Consequences

- Adding a machine: register it in `hosts/default.nix`, create
  `hosts/<hostname>/default.nix`, and — only if it needs a user environment —
  `hosts/<hostname>/home.nix` plus `userEnvironment = true`.
- Answering "what is different about this machine?" now reads two places:
  `hosts/default.nix` for capabilities and software, `hosts/<hostname>/` for
  everything else.
- `home/` is gone; all references in `GLOSSARY.md`, `CONTEXT.md`, `README.md`,
  `docs/module-reference.md` and ADR-0014 were updated in the same change.
- ADR-0007's remaining claims are fully superseded: a Machine File no longer
  lists imports, no longer carries a switch table, and is no longer discovered
  by file presence.
- The `home/<hostname>.nix` → `hosts/<hostname>/home.nix` move changed the path
  that `mkOutOfStoreDotfiles` pointed at. That helper and its out-of-store links
  were removed later in favour of in-store links (`source = ./config/…`), which
  do not depend on where the repository is checked out.
