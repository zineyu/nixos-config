{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.fd;
in
{
  options.zine.programs.fd.enable = lib.mkEnableOption "fd find 替代";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fd ];
  };
}
