{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.curl;
in
{
  options.zine.programs.curl.enable = lib.mkEnableOption "curl";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.curl ];
  };
}
