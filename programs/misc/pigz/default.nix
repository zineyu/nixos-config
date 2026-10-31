{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.pigz;
in
{
  options.zine.programs.pigz.enable = lib.mkEnableOption "pigz 并行 gzip";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pigz ];
  };
}
