{ pkgs, ... }:
let
  rime-flypy = pkgs.callPackage ../../../pkgs/rime-flypy.nix { };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      rime-data
      rime-ice
      rime-flypy
      qt6Packages.fcitx5-configtool
      kdePackages.fcitx5-qt
    ];
  };
}
