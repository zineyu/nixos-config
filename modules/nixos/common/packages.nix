# 系统级软件清单（所有 host 共享）：声明安装哪些系统软件，配置见同目录其他模块。
{ pkgs, ... }:

{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
}
