# 用户级桌面环境层（niri、DankMaterialShell、字体、图标等）。
# 由使用 Wayland 桌面的机器组织文件显式导入；导入即启用。
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # niri 下的 X11 与剪贴板工具
    xwayland-satellite
    wl-clipboard

    # 字体
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    fira-code
    maple-mono.NF-CN
  ];

  imports = [
    ./niri.nix
    ./dank-material-shell.nix
    ./env.nix
    ./fontconfig
    ./tela-icon-theme
    ./xdg-user-dirs
  ];
}
