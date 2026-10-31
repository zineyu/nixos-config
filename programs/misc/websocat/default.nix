{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.websocat;
in
{
  options.zine.programs.websocat.enable = lib.mkEnableOption "websocat WebSocket 客户端";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.websocat ];
  };
}
