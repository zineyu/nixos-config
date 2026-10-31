{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.lnav;
in
{
  options.zine.programs.lnav.enable = lib.mkEnableOption "lnav 日志浏览";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lnav ];
  };
}
