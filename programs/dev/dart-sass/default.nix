{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.dart-sass;
in
{
  options.zine.programs.dart-sass.enable = lib.mkEnableOption "dart-sass";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.dart-sass ];
  };
}
