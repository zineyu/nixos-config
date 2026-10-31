{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.zoxide;
in
{
  options.zine.programs.zoxide.enable = lib.mkEnableOption "zoxide 目录跳转";

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
