# Host module for the `tianxuan` machine.
#
# This module imports the system configuration and wires the user entry
# into Home Manager. It is consumed by flake.nix via `import ./hosts/${hostname}`.
{
  imports = [ ./configuration.nix ];

  home-manager.users.zine = import ../../users/zine;
}
