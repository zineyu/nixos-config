# Build a Home Manager configuration for a given user and system.
#
# Interface:
#   { username, system, modules ? [], outputs ? {} }
# Returns:
#   home-manager.lib.homeManagerConfiguration
{ inputs, nixpkgs, home-manager, ... }:

{ username
, system
, modules ? []
, outputs ? {}
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { inherit system; };
  inherit modules;
  extraSpecialArgs = { inherit inputs outputs username; };
}
