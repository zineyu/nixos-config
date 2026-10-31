{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.fzf;
in
{
  options.zine.programs.fzf.enable = lib.mkEnableOption "fzf 模糊查找";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fzf ];
  };
}
