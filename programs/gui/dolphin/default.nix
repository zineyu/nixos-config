{
  host,
  lib,
  pkgs,
  ...
}:

{
  # 缺席轴：KDE 文件管理器，macOS 用 Finder（ADR-0018）。
  config = lib.mkIf (host.hasTag "gui" && host.platform.nixos) {
    home.packages = [ pkgs.kdePackages.dolphin ];

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "inode/directory" = lib.mkDefault "org.kde.dolphin.desktop";
      };
      associations.added = {
        "inode/directory" = lib.mkDefault "org.kde.dolphin.desktop";
      };
    };
  };
}
