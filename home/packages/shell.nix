# Shell 与提示符。配置见 home/shell/。
{ config, lib, ... }:

let
  cfg = config.zine.programs;
in
{
  options.zine.programs = {
    fish.enable = lib.mkEnableOption "fish";
    bash.enable = lib.mkEnableOption "bash";
    starship.enable = lib.mkEnableOption "starship";
  };

  config = {
    programs.fish.enable = cfg.fish.enable;
    programs.bash.enable = cfg.bash.enable;
    programs.starship.enable = cfg.starship.enable;
  };
}
