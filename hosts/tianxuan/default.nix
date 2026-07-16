# Host module for the `tianxuan` machine.
#
# This module imports the system configuration and wires the single user
# Home Manager entry into NixOS. It is consumed by flake.nix via
# `import ./hosts/${hostname}`.
{ ... }:
{
  imports = [ ./configuration.nix ];

  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(control, esc)";
        };
      };
    };
  };

  home-manager.users.zine = import ../../modules/home;
}
