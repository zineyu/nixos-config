{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.lazygit;
in
{
  options.zine.programs.lazygit.enable = lib.mkEnableOption "lazygit TUI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];
  };
}
