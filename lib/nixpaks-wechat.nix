{
  lib,
  pkgs,
  wechat,
  buildEnv,
  mkNixPak,
  makeWrapper,
  makeDesktopItem,
}:
let
  appId = "com.tencent.WeChat";

  wechat-wrapped =
    pkgs.runCommand "wechat-wrapped"
      {
        nativeBuildInputs = [ makeWrapper ];
        meta = {
          mainProgram = "wechat";
        };
      }
      ''
        mkdir -p $out/bin
        makeWrapper '${wechat}/bin/wechat' "$out/bin/wechat" \
          --set QT_QPA_PLATFORM xcb \
          --set QT_IM_MODULE fcitx \
          --set GTK_IM_MODULE fcitx \
          --set XMODIFIERS @im=fcitx

        mkdir -p $out/share/applications
        cp '${wechat}/share/applications/wechat.desktop' $out/share/applications/

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp '${wechat}/share/icons/hicolor/256x256/apps/wechat.png' $out/share/icons/hicolor/256x256/apps/
      '';

  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = wechat-wrapped;
        flatpak = { inherit appId; };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.FileManager1" = "talk";
            "org.freedesktop.Notifications" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
          };
        };
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
          bind.ro = [
            "/etc/passwd"
            "/etc/machine-id"
          ];
          bind.rw = with sloth; [
            xdgDownloadDir
            [
              (mkdir (concat' appDir "/xwechat_files"))
              (concat' homeDir "/xwechat_files")
            ]
          ];
          env = {
            QT_QPA_PLATFORM = "xcb";
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
            QT_IM_MODULE = "fcitx";
            GTK_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
          };
        };
      };
  };
  exePath = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "WeChat";
      genericName = "WeChat";
      comment = "WeChat";
      exec = "${exePath} %U";
      icon = "${wechat}/share/icons/hicolor/256x256/apps/wechat.png";
      type = "Application";
      categories = [
        "InstantMessaging"
        "Network"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
