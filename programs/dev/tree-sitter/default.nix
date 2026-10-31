{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.tree-sitter;
in
{
  options.zine.programs.tree-sitter.enable = lib.mkEnableOption "tree-sitter CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tree-sitter ];
  };
}
