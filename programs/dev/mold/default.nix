{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.mold;
in
{
  options.zine.programs.mold.enable = lib.mkEnableOption "mold 链接器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.mold ];
  };
}
