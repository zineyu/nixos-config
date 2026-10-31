{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.localsend;
in
{
  options.zine.programs.localsend.enable = lib.mkEnableOption "LocalSend 局域网传输";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.localsend ];
  };
}
