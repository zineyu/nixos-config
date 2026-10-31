{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.firefox;
in
{
  options.zine.programs.firefox.enable = lib.mkEnableOption "Firefox";

  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;
  };
}
