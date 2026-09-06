# 桌面系统级软件清单：声明安装哪些桌面软件/游戏平台，配置见同目录其他模块。
{ ... }:

{
  programs = {
    steam.enable = true;
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    kdeconnect.enable = true;
  };
}
