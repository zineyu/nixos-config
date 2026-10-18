# Host module for the `tianxuan` machine.
#
# Only system-level overrides specific to this machine belong here.
# The user environment is wired by lib/mkSystem.nix from home/tianxuan.nix.
{ ... }:
{
  imports = [ ./configuration.nix ];

  # GRUB (EFI mode) is the boot loader for this host.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 20;
  };

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
}
