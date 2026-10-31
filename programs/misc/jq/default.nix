{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.jq;
in
{
  options.zine.programs.jq.enable = lib.mkEnableOption "jq JSON 处理";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.jq ];
  };
}
