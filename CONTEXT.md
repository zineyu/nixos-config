# Personal NixOS configuration context

This repository builds complete NixOS and nix-darwin systems for personal
machines, using a single flake that combines system-level modules with
user-level Home Manager modules. Pure software lives in `programs/`; system-side
configuration lives in `modules/`.

The domain language lives in [`GLOSSARY.md`](./GLOSSARY.md). Every term below
follows it.

## Example dialogue

> **Explorer**: I want to add a new keyboard daemon for the desktop host. Where
> does it go?
>
> **Maintainer**: If it is software the user runs, create a Program Module under
> `programs/<category>/<name>/` and enable `zine.programs.<name>` in the Machine
> File. If it is a system service, put it in `modules/nixos/` and import it from
> the Host.
>
> **Explorer**: Where does a user-level systemd timer go?
>
> **Maintainer**: `modules/base/services/`, behind a `zine.services.<name>`
> switch, and enabled in the Machine File.
>
> **Explorer**: Why is `ccache` only enabled on `tianxuan`?
>
> **Maintainer**: Because `macbook-air-01` is Darwin and `ccache` pulls a
> Linux-only build input. With one option per program, that is one line in the
> Machine File instead of a bundle that fails to evaluate.
>
> **Explorer**: What is the difference between a Host and a Machine File?
>
> **Maintainer**: The Host is system-level. The Machine File selects the
> user-level software for that same machine. `lib/mkSystem.nix` connects them.
