{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.unzip;
in
{
  options.zine.programs.unzip.enable = lib.mkEnableOption "unzip";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unzip ];
  };
}
