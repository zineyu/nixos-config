{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.lazyjj;
in
{
  options.zine.programs.lazyjj.enable = lib.mkEnableOption "lazyjj TUI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lazyjj ];
  };
}
