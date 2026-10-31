{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.stylua;
in
{
  options.zine.programs.stylua.enable = lib.mkEnableOption "stylua Lua 格式化";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.stylua ];
  };
}
