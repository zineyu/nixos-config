# 有配置的图形界面程序：逐个 option 门控。
# 配置见 modules/home/programs/gui/；裸 GUI 包见 gui-extras.nix（opt-in）。
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.zine.programs;
  system = pkgs.stdenv.hostPlatform.system;
  dbx-desktop =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.callPackage ../../../pkgs/dbx-desktop-darwin.nix { }
    else
      inputs.dbx.packages.${system}.dbx-desktop;
in
{
  options.zine.programs = {
    firefox.enable = lib.mkEnableOption "Firefox";
    chromium.enable = lib.mkEnableOption "Chromium";
    thunderbird.enable = lib.mkEnableOption "Thunderbird";
    dbx-desktop.enable = lib.mkEnableOption "DBX Desktop";
    zen-browser.enable = lib.mkEnableOption "Zen Browser";
    dolphin.enable = lib.mkEnableOption "Dolphin 文件管理器";
  };

  config = {
    programs = {
      firefox.enable = cfg.firefox.enable;
      chromium.enable = cfg.chromium.enable;
      thunderbird.enable = cfg.thunderbird.enable;
      zen-browser.enable = cfg.zen-browser.enable;
    };

    home.packages =
      lib.optionals cfg.dbx-desktop.enable [
        dbx-desktop
      ]
      ++ lib.optionals cfg.dolphin.enable [ pkgs.kdePackages.dolphin ];
  };
}
