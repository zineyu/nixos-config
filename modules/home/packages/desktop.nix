# 桌面环境组件（仅 Linux 桌面，由 packages/default.nix 通过 linuxOnly 引入）。
# 配置见 desktop/。
{ pkgs, ... }:

{
  programs.dank-material-shell.enable = true;

  home.packages = with pkgs; [
    # niri 下的 X11 应用支持
    xwayland-satellite

    # 字体
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    fira-code
    maple-mono.NF-CN
  ];

  # 图标主题 tela-icon-theme 由 desktop/tela-icon-theme 的
  # gtk.iconTheme.package 负责安装。
}
