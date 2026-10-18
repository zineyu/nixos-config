# GUI 裸包：无独立配置模块的图形界面软件（含 nixpak 沙盒化的聊天客户端）。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.bundles.gui;
in
{
  options.zine.bundles.gui.enable = lib.mkEnableOption "GUI 裸包捆绑";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      localsend
      nixpaks.qq
      nixpaks.wechat
      (pkgs.callPackage ../../../pkgs/breezex-cursor.nix { })
    ];
  };
}
