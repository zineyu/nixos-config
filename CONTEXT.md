# Personal NixOS configuration context

This repository builds complete NixOS and nix-darwin systems for personal
machines, using a single flake that combines system-level modules with
user-level Home Manager modules. Composition follows **broadcast-and-gate**:
every module tree is imported by every host of its platform, and each module
decides for itself whether to activate by reading Host Metadata. Pure software
lives in `programs/`; system-side configuration lives in `modules/`.

The domain language lives in [`GLOSSARY.md`](./GLOSSARY.md). Every term below
follows it.

## Example dialogue

> **Explorer**: I want to add a new keyboard daemon for the desktop host. Where
> does it go?
>
> **Maintainer**: If it is software the user runs, create a Program Module under
> `programs/<category>/<name>/` and let the module state the capability it
> needs — `gui`, `desktop`, or `host.kind`; a program that needs none joins the
> baseline and is not gated. If it is an optional system service, create a
> System Capability under `modules/nixos/optional/` gated on a Tag, register the
> Tag in `modules/host-metadata.nix`, and tag the host. There is no switch to
> set and no software list to edit. Configuration that every NixOS host needs
> belongs in `modules/nixos/common/` instead.
>
> **Explorer**: Where does a user-level systemd timer go?
>
> **Maintainer**: `modules/base/services/`, gated on a Tag. Nothing in the host
> files changes.
>
> **Explorer**: How do I turn Docker off for one host?
>
> **Maintainer**: Remove the `docker` Tag from that host. There is no switch to
> flip: the gate *is* the metadata.
>
> **Explorer**: Why is `ccache` only installed on `tianxuan` and `work-hp-laptop`?
>
> **Maintainer**: Because its module requires `host.kind == "nixos"`, and
> `macbook-air-01` is Darwin. Nothing in the host files mentions ccache.
>
> **Explorer**: What happens if I tag a host with something that does not exist?
>
> **Maintainer**: Evaluation fails. `tags` is typed as an enum over the
> vocabulary in `modules/host-metadata.nix`, so a typo is an error rather than a
> capability that silently never turns on.
>
> **Explorer**: Why are there two files per machine?
>
> **Maintainer**: Because they are two module namespaces, not two copies of
> anything. `hosts/<hostname>/default.nix` is NixOS or nix-darwin and holds
> machine facts; `hosts/<hostname>/home.nix` is Home Manager and holds
> user-level overrides that cannot live anywhere else — usually nothing.
> Software selection is Host Metadata, in the Host Inventory, and
> `userEnvironment = true` is what makes a Machine File exist; the file itself
> is never the signal.

```mermaid
graph TD
    Inv["hosts/inventory.nix<br/>tags"] --> Mk["lib/mkSystem.nix<br/>specialArgs.host"]
    Mk --> Nix["modules/nixos"]
    Mk --> Dar["modules/darwin"]
    Mk --> HM["home-manager.sharedModules<br/>base + programs + desktop/home"]
    Nix --> G1["common: always"]
    Nix --> G2["optional: per tag"]
    Nix --> G3["server: server"]
    Nix --> G4["desktop/system: desktop"]
    Nix --> G5["wsl / nvidia / mihomo: tag"]
    Dar --> G6["sops: always"]
    Dar --> G7["tailscale / remote-login / mihomo: tag"]
    HM --> G8["programs/*: each declares its capability"]
    HM --> G9["desktop/home: desktop"]
```
