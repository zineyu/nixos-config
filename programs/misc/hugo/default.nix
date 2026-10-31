{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.hugo;
in
{
  options.zine.programs.hugo.enable = lib.mkEnableOption "hugo 静态站点生成器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.hugo ];
  };
}
