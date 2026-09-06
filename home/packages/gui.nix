# 有配置的图形界面程序（仅 Linux 桌面机器导入，见 home/tianxuan.nix）：
# 逐个 option 门控。配置见 home/programs/gui/；裸 GUI 包见 gui-extras.nix（opt-in）。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs;
in
{
  options.zine.programs = {
    firefox.enable = lib.mkEnableOption "Firefox";
    chromium.enable = lib.mkEnableOption "Chromium";
    thunderbird.enable = lib.mkEnableOption "Thunderbird";
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

    home.packages = with pkgs; lib.optionals cfg.dolphin.enable [ kdePackages.dolphin ];
  };
}
