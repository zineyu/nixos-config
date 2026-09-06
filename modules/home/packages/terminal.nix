# 终端与终端增强工具。配置见 modules/home/programs/terminal/。
{ config, lib, ... }:

let
  cfg = config.zine.programs;
in
{
  options.zine.programs = {
    kitty.enable = lib.mkEnableOption "kitty 终端";
    atuin.enable = lib.mkEnableOption "atuin shell 历史";
    yazi.enable = lib.mkEnableOption "yazi 文件管理器";
    zellij.enable = lib.mkEnableOption "zellij 终端复用器";
    zoxide.enable = lib.mkEnableOption "zoxide 目录跳转";
  };

  config = {
    programs = {
      kitty.enable = cfg.kitty.enable;
      atuin.enable = cfg.atuin.enable;
      yazi.enable = cfg.yazi.enable;
      zellij.enable = cfg.zellij.enable;
      zoxide.enable = cfg.zoxide.enable;
    };
  };
}
