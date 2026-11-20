# Programs declare the capability they need

## Status

Accepted (supersedes ADR-0014's `programs` list; constrains the Tag vocabulary)

## Date

2026-11-20

## Context

ADR-0014 moved software selection out of the machine files and into the Host
Inventory's `programs` list. That removed the switch table, but it put a list of
86 program names into `hosts/default.nix` for `tianxuan` alone — the largest
hand-maintained table in the repository, and one that had to be edited every time
a program was added or dropped. It also meant a capability-driven repository
still answered "what software does this machine run?" from a list rather than
from what the machine is.

The obvious repair — express the list as capabilities — was attempted and
rejected on review. Splitting the software into buckets named `dev-base` and
`dev-extra` produced labels that describe no property of a machine; they were the
old list in disguise, and any host that wanted a different subset would need yet
another bucket. A tag vocabulary is only worth having if every tag is a fact
about the machine that a person could state without looking at this repository.

## Decision

**A Program Module declares the capability it needs. There is no program list.**

- **Baseline.** A program that needs no capability is part of the User
  Environment and is not gated at all. Its module returns
  `config = { … };` — the option tree it configures is only instantiated for
  hosts that have a User Environment in the first place.
- **Session.** A program that needs a graphical session gates on `gui`:
  `lib.mkIf host.gates.gui`.
- **Stack.** A program that needs the Wayland desktop stack (or an overlay that
  tree provides, such as `pkgs.nixpaks`) gates on `desktop`.
- **Platform.** A program that only exists on one platform gates on
  `host.kind` — `ccache` and `mold` on NixOS, `karabiner-elements` on Darwin.
- **A Tag must be a property of the machine.** Machine form (`desktop`,
  `server`, `wsl`), session (`gui`), and system capability (`docker`, `sshd`,
  `tailscale`, `mihomo`, `nvidia`, `remote-login`, `headscale-backup`). Software
  groupings are not admissible, because a tag that exists to reproduce a former
  list is that list with worse ergonomics.

## Alternatives Considered

### Keep the `programs` list (ADR-0014 as written)

- Pros: exact control; a machine can have any subset of programs.
- Cons: 86 hand-maintained names per host; the repository's largest table; the
  answer to "what runs here" is a list of strings with no relationship to what
  the machine is.
- Rejected: it contradicts the reason the composition model was changed at all.

### Invent capability buckets (`dev-base`, `dev-extra`, `cli-tools`)

- Pros: reproduces the existing per-host sets exactly; the list moves into the
  modules.
- Cons: those are not capabilities. They are grouping labels chosen to match the
  current answer, and a host that diverges needs a new bucket, so the vocabulary
  grows into a vocabulary of hosts.
- Rejected on review.

### Named profiles selected by metadata

- Pros: a small vocabulary, one indirection.
- Cons: profiles are software groupings under another name, and they hide the
  per-module decision the model is supposed to make.
- Rejected: the module decides, not a central table.

## Consequences

- Software is now a function of what the machine is. `gui` brings the graphical
  applications, `desktop` brings the desktop-only ones, and the rest is baseline.
- **Per-program opt-out is no longer expressible.** A machine cannot have
  `firefox` without `chromium`. Removing one program from one machine now means
  finding the capability that program genuinely depends on, or accepting it. This
  is the deliberate cost of the model.
- The installed sets change. `macbook-air-01` gains the `gui` applications it
  previously lacked, and `work-hp-laptop` gains the baseline developer and CLI
  toolchain. Exact reproduction was explicitly not a goal.
- Adding a program: write the module and choose its gate. Nothing in
  `hosts/default.nix` changes.
- Tangible reductions: `host.programs` is gone from the metadata, `zine.host`
  loses the field, and the inventory shrinks to machine form plus capabilities.
- `rime-ice` gates on `desktop`, so it activates on the only desktop host. It was
  previously inert; its Darwin-only Squirrel app/config remain gated inside the
  module.

## Update (same day): gate form

The first cut of this decision wrote gates as `lib.mkIf (lib.elem "gui" host.tags)`.
That reintroduced the silent-failure mode the Tag vocabulary exists to prevent: the
inventory's tags are enum-checked, but a *string literal inside a module* is not,
so `(lib.elem "giu" host.tags)` would quietly evaluate to `false` and the program
would simply never install.

`lib/mkSystem.nix` now derives `gates = lib.genAttrs hostTags (tag: lib.elem tag tags)`
from the vocabulary in `lib/host-tags.nix`, and every gate reads `host.gates.<tag>`.
Because that projection is total over the vocabulary, a misspelled gate name is
`attribute 'giu' missing` at evaluation time. It travels through `specialArgs`, so
`imports` can use it without touching `config`. `zine.host.gates` mirrors it for
`nix eval` auditing.
