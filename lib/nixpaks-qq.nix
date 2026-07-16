{
  lib,
  pkgs,
  qq,
  libx11,
  libkrb5,
  stdenv,
  buildEnv,
  mkNixPak,
  makeWrapper,
  makeDesktopItem,
}:
let
  appId = "com.qq.QQ";

  qq-wrapped =
    pkgs.runCommand "qq-wrapped"
      {
        nativeBuildInputs = [ makeWrapper ];
        meta = {
          mainProgram = "qq";
        };
      }
      ''
        mkdir -p $out/bin
        makeWrapper '${qq}/bin/qq' "$out/bin/qq" \
          --prefix LD_LIBRARY_PATH : '${
            lib.makeLibraryPath [
              libx11
              libkrb5
              stdenv.cc.cc
            ]
          }'
      '';

  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = qq-wrapped;
        flatpak = { inherit appId; };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.Notifications" = "talk";
            "org.freedesktop.ScreenSaver" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
            "org.freedesktop.login1" = "talk";
          };
        };
        bubblewrap = {
          sockets = {
            wayland = true;
            x11 = true;
          };
          bind.rw = [ "xdg/Downloads" ];
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
      desktopName = "QQ";
      genericName = "QQ";
      comment = "Tencent QQ";
      exec = "${exePath} %U";
      icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
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
