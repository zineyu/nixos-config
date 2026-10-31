{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.qq;
in
{
  options.zine.programs.qq.enable = lib.mkEnableOption "QQ（nixpak 沙盒）";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nixpaks.qq ];
  };
}
