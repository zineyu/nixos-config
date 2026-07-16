{
  lib,
  sloth,
  config,
  ...
}:
{
  locale.enable = true;

  gpu = {
    enable = true;
    provider = "nixos";
  };

  etc.sslCertificates.enable = true;

  dbus =
    let
      inherit (config.flatpak) appId;
    in
    {
      enable = true;
      policies = {
        "${appId}" = "own";
        "${appId}.*" = "own";
        "org.freedesktop.DBus" = "talk";
        "org.freedesktop.Notifications" = "talk";
        "org.freedesktop.portal.*" = "talk";
        "org.freedesktop.portal.Fcitx" = "talk";
        "org.freedesktop.portal.Fcitx.*" = "talk";
        "org.kde.StatusNotifierWatcher" = "talk";
        "org.gtk.vfs" = "talk";
        "org.gtk.vfs.*" = "talk";
        "ca.desrt.dconf" = "talk";
      };
      rules = {
        call = {
          "org.freedesktop.Notifications.*" = [ "*" ];
          "org.freedesktop.portal.Desktop" = [ "*" ];
          "org.freedesktop.portal.Fcitx" = [ "*" ];
          "org.freedesktop.portal.Fcitx.*" = [ "*" ];
        };
      };
    };

  bubblewrap = {
    network = lib.mkDefault true;
    sockets = {
      wayland = true;
      pulse = true;
    };
    bind.rw = with sloth; [
      [
        (mkdir appDataDir)
        xdgDataHome
      ]
      [
        (mkdir appConfigDir)
        xdgConfigHome
      ]
      [
        (mkdir appCacheDir)
        xdgCacheHome
      ]
      (sloth.concat [
        sloth.runtimeDir
        "/"
        (sloth.envOr "WAYLAND_DISPLAY" "no")
      ])
      (sloth.concat' sloth.xdgCacheHome "/fontconfig")
      (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
    ];
    bind.ro = [
      (sloth.concat' sloth.xdgConfigHome "/fontconfig")
      (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
      (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
      "/etc/fonts"
      "/etc/localtime"
    ];
    bind.dev = [ "/dev/shm" ];
    tmpfs = [ "/tmp" ];
  };
}
