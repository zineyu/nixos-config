{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.resvg;
in
{
  options.zine.programs.resvg.enable = lib.mkEnableOption "resvg SVG 渲染";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.resvg ];
  };
}
