{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.devenv;
in
{
  options.zine.programs.devenv.enable = lib.mkEnableOption "devenv";

  config = lib.mkIf cfg.enable {
    programs.devenv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
