{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.thunderbird;
in
{
  options.zine.programs.thunderbird.enable = lib.mkEnableOption "Thunderbird";

  config = lib.mkIf cfg.enable {
    programs.thunderbird.enable = true;
  };
}
