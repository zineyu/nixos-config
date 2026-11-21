# 用户级桌面环境层（niri、DankMaterialShell、字体、图标等）。
#
# 广播-门控：被 lib/mkSystem.nix 无条件加入 home-manager.sharedModules，
# 只有带 "gui" 标签的 Linux host 生效：niri 与 DankMaterialShell 是 Wayland
# 桌面，macOS 上求值不了，WSL 上也没有要接管的图形会话。
{
  host,
  lib,
  pkgs,
  ...
}:
let
  desktop = host.hasTag "gui" && host.platform.linux;
in
{
  imports = lib.optionals desktop [
    ./niri.nix
    ./dank-material-shell.nix
    ./env.nix
    ./fontconfig
    ./tela-icon-theme
    ./xdg-user-dirs
  ];

  home.packages = lib.optionals desktop (
    with pkgs;
    [
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
    ]
  );
}
