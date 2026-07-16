{
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
}
