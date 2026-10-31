{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.eza;
in
{
  options.zine.programs.eza.enable = lib.mkEnableOption "eza ls 替代";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eza ];
  };
}
