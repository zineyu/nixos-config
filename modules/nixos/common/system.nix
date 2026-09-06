{ pkgs, ... }:

{
  # Bootloader is configured per-host (see hosts/<hostname>/).
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
