# 用户级桌面环境组件（niri、DMS、字体、图标等，仅 Linux 桌面机器导入，
# 见 home/tianxuan.nix）。
{ ... }:

{
  imports = [
    ./niri.nix
    ./dank-material-shell.nix
    ./env.nix
    ./fontconfig
    ./tela-icon-theme
    ./xdg-user-dirs
  ];
}
