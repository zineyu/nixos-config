{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.chafa;
in
{
  options.zine.programs.chafa.enable = lib.mkEnableOption "chafa 图片转字符终端工具";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.chafa ];
  };
}
