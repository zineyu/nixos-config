{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.pandoc;
in
{
  options.zine.programs.pandoc.enable = lib.mkEnableOption "pandoc 文档转换";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pandoc ];
  };
}
