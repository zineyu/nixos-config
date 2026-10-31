{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.uv;
in
{
  options.zine.programs.uv.enable = lib.mkEnableOption "uv Python 包管理器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.uv ];
  };
}
