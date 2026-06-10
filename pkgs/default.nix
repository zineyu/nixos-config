# Custom packages derived from this flake.
# Expose these via `packages.${system}` in flake.nix.
{ pkgs ? import <nixpkgs> { } }:

{
  # Example: my-tool = pkgs.callPackage ./my-tool { };
}
