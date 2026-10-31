{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.dbeaver;
in
{
  options.zine.programs.dbeaver.enable = lib.mkEnableOption "DBeaver";

  config = lib.mkIf cfg.enable {
    programs.dbeaver.enable = true;
  };
}
