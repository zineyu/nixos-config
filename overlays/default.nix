# Custom overlays for nixpkgs.
# Import this in flake.nix to apply package overrides across all hosts.
final: prev:

{
  # Example: override a package version or apply a patch.
  # my-package = prev.my-package.override { ... };
}
