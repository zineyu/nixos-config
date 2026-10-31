{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.zip;
in
{
  options.zine.programs.zip.enable = lib.mkEnableOption "zip";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zip ];
  };
}
