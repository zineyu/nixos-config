# 用户级桌面环境组件（niri、DMS、字体、图标等）。
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
