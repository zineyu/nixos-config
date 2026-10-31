{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.gcc;
in
{
  options.zine.programs.gcc.enable = lib.mkEnableOption "GCC";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gcc ];
  };
}
