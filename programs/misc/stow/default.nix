{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.stow;
in
{
  options.zine.programs.stow.enable = lib.mkEnableOption "stow 符号链接部署";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.stow ];
  };
}
