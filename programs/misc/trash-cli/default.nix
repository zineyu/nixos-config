{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.trash-cli;
in
{
  options.zine.programs.trash-cli.enable = lib.mkEnableOption "trash-cli 回收站命令";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.trash-cli ];
  };
}
