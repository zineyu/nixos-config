{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.bat;
in
{
  options.zine.programs.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bat ];
  };
}
