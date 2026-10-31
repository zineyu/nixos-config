{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.just;
in
{
  options.zine.programs.just.enable = lib.mkEnableOption "just 任务运行器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.just ];
  };
}
