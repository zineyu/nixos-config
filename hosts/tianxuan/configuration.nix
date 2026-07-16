# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ vars, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/graphics.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/i18n.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/steam.nix
  ];

  # Host-specific NVIDIA Optimus configuration.
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = vars.linux.hardware.intelBusId;
    nvidiaBusId = vars.linux.hardware.nvidiaBusId;
  };

  # Host-specific networking.
  networking.hostName = vars.linux.hostname;

  services.mihomo = {
    enable = true;
    configFile = "/home/zine/.config/mihomo/config.yaml";
    tunMode = true;
  };

  # Host-specific timezone.
  time.timeZone = "Asia/Shanghai";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you have upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages or OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system configuration is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your
  # configuration, and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
