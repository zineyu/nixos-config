{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.go;
in
{
  options.zine.programs.go.enable = lib.mkEnableOption "Go 工具链";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.go ];
  };
}
