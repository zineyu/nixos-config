{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.gnumake;
in
{
  options.zine.programs.gnumake.enable = lib.mkEnableOption "GNU make";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gnumake ];
  };
}
