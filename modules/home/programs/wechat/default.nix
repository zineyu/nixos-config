{ pkgs, ... }:

let
  wechat = pkgs.wechat;

  # WeChat 的 AppImage 使用静态链接的 Qt5，但当前版本（4.1.1.4）已内置
  # QFcitxPlatformInputContextPlugin，无需依赖系统 fcitx5-qt 插件。
  # 强制 X11 平台可避免 Wayland 下可能存在的焦点/兼容问题，并选择内置的
  # fcitx 输入上下文插件连接 Fcitx5。
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
          --set QT_IM_MODULE fcitx \
          --set GTK_IM_MODULE fcitx \
          --set XMODIFIERS @im=fcitx

        mkdir -p $out/share/applications
        cp ${wechat}/share/applications/wechat.desktop $out/share/applications/

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp ${wechat}/share/icons/hicolor/256x256/apps/wechat.png $out/share/icons/hicolor/256x256/apps/
      '';
in
{
  home.packages = [ wechat-wrapped ];
}
