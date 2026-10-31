{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.cmake;
in
{
  options.zine.programs.cmake.enable = lib.mkEnableOption "CMake";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cmake ];
  };
}
