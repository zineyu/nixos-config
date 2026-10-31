{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.fastfetch;
in
{
  options.zine.programs.fastfetch.enable = lib.mkEnableOption "fastfetch";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fastfetch ];
  };
}
