{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.wechat;
in
{
  options.zine.programs.wechat.enable = lib.mkEnableOption "微信（nixpak 沙盒）";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nixpaks.wechat ];
  };
}
