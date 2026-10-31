{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.chezmoi;
in
{
  options.zine.programs.chezmoi.enable = lib.mkEnableOption "chezmoi dotfiles 管理器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.chezmoi ];
  };
}
