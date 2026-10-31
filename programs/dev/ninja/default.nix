{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.ninja;
in
{
  options.zine.programs.ninja.enable = lib.mkEnableOption "Ninja 构建系统";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ninja ];
  };
}
