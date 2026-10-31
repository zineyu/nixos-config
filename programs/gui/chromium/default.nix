{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.chromium;
in
{
  options.zine.programs.chromium.enable = lib.mkEnableOption "Chromium";

  config = lib.mkIf cfg.enable {
    programs.chromium.enable = true;
  };
}
