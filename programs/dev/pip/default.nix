{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.pip;
in
{
  options.zine.programs.pip.enable = lib.mkEnableOption "pip（python3Packages.pip）";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.python3Packages.pip ];
  };
}
