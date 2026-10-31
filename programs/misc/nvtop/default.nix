{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.nvtop;
in
{
  options.zine.programs.nvtop.enable = lib.mkEnableOption "nvtop GPU 监视器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nvtopPackages.full ];
  };
}
