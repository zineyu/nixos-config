{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.bun;
in
{
  options.zine.programs.bun.enable = lib.mkEnableOption "bun JavaScript 运行时";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bun ];
  };
}
