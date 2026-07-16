# Host module for the `tianxuan` machine.
#
# This module imports the system configuration and wires the user entry
# into Home Manager. It is consumed by flake.nix via `import ./hosts/${hostname}`.
{ vars, ... }:
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

  home-manager.users."${vars.linux.user.name}" = import ../../users/zine;
}
