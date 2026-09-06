# 桌面环境组件。配置见 modules/home/desktop/。
{ pkgs, ... }:

{
  programs.dank-material-shell.enable = true;

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

  # 图标主题 tela-icon-theme 由 desktop/tela-icon-theme 的
  # gtk.iconTheme.package 负责安装。
}
