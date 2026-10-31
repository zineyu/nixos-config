{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.python3;
in
{
  options.zine.programs.python3.enable = lib.mkEnableOption "Python 3 解释器";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.python3 ];
  };
}
