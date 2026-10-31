{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.tree;
in
{
  options.zine.programs.tree.enable = lib.mkEnableOption "tree 目录树";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tree ];
  };
}
