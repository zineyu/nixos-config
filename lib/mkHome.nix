# Build a Home Manager configuration for a given user and system.
#
# Interface:
#   { username, hostname, system, modules ? [] }
# Returns:
#   home-manager.lib.homeManagerConfiguration
{
  inputs,
  nixpkgs,
  home-manager,
  ...
}:

{
  username,
  hostname,
  system,
  modules ? [ ],
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  inherit modules;
  extraSpecialArgs = { inherit inputs username hostname; };
}
