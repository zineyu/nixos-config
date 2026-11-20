{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
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
