{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.maven;
in
{
  options.zine.programs.maven.enable = lib.mkEnableOption "Maven";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.maven ];
  };
}
