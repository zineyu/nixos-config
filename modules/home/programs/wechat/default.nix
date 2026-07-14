{ pkgs, ... }:

let
  wechat = pkgs.wechat;

  # WeChat 的 AppImage 使用静态链接的 Qt5，无法加载 NixOS 的 fcitx5-qt 插件。
  # Fcitx5 提供 IBus 兼容前端，而 Qt5 自带 IBus 输入上下文插件。
  # 强制 X11 平台可确保 Qt 的 IBus 插件读取到正确的 IBUS 地址文件。
  wechat-wrapped =
    pkgs.runCommand "wechat"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        inherit (wechat) meta;
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${wechat}/bin/wechat $out/bin/wechat \
          --set QT_QPA_PLATFORM xcb \
          --set QT_IM_MODULE ibus \
          --set GTK_IM_MODULE xim

        mkdir -p $out/share/applications
        cp ${wechat}/share/applications/wechat.desktop $out/share/applications/

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp ${wechat}/share/icons/hicolor/256x256/apps/wechat.png $out/share/icons/hicolor/256x256/apps/
      '';
in
{
  home.packages = [ wechat-wrapped ];
}
