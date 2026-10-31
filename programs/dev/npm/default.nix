{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.npm;
in
{
  options.zine.programs.npm.enable = lib.mkEnableOption "npm 配置";

  config = lib.mkIf cfg.enable {
    programs.npm = {
      enable = true;
      settings.prefix = "${config.home.homeDirectory}/.npm-global";
    };
  };
}
