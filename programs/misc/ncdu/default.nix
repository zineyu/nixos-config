{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.ncdu;
in
{
  options.zine.programs.ncdu.enable = lib.mkEnableOption "ncdu 磁盘用量";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ncdu ];
  };
}
