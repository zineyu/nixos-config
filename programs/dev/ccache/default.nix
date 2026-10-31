{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.ccache;
in
{
  options.zine.programs.ccache.enable = lib.mkEnableOption "ccache 编译缓存";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ccache ];
  };
}
