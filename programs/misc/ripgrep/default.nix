{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.ripgrep;
in
{
  options.zine.programs.ripgrep.enable = lib.mkEnableOption "ripgrep grep 替代";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];
  };
}
