# 用户级桌面环境层（niri、DankMaterialShell、字体、图标等）。
#
# 广播-门控：被 lib/mkSystem.nix 无条件加入 home-manager.sharedModules，
# 只有带 "desktop" tag 的 host 生效。
{ host, lib, pkgs, ... }:
let
  desktop = host.gates.desktop;
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
