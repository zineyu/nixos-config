# Build a Home Manager configuration for a given user and system.
#
# Interface:
#   { username, system, modules ? [] }
# Returns:
#   home-manager.lib.homeManagerConfiguration
{
  inputs,
  nixpkgs,
  home-manager,
  ...
}:

{ username
, system
, modules ? []
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { inherit system; };
  modules = [ ../profiles/common.nix ] ++ modules;
  extraSpecialArgs = { inherit inputs username; };
}
