{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.mise;
in
{
  options.zine.programs.mise.enable = lib.mkEnableOption "mise 运行时管理器";

  config = lib.mkIf cfg.enable {
    programs.mise.enable = true;
    programs.mise.enableFishIntegration = true;
  };
}
