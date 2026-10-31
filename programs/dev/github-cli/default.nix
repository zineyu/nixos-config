{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.github-cli;
in
{
  options.zine.programs.github-cli.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.github-cli ];
  };
}
