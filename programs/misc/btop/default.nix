{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.btop;
in
{
  options.zine.programs.btop.enable = lib.mkEnableOption "btop 系统监视器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.btop ];
  };
}
