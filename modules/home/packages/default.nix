# 集中包清单：声明系统包含哪些软件（安装侧），配置见 modules/home/programs/ 等。
# 有 Home Manager 模块的软件用 programs.<name>.enable 声明安装，裸包直接进 home.packages；
# 自定义/外部包定义统一放在仓库根 pkgs/ 目录。
{ extraLibs, ... }:

{
  imports = [
    ./tools.nix
    ./shell.nix
    ./dev.nix
    ./terminal.nix
    ./misc.nix
  ]
  ++ map extraLibs.linuxOnly [
    ./gui.nix
    ./desktop.nix
  ];
}
