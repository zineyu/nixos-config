{
  lib,
  pkgs,
  ...
}:

{
  xdg.mimeApps.enable = true;

  home.packages = [ pkgs.kdePackages.dolphin ];

  xdg.mimeApps = {
    defaultApplications = {
      "inode/directory" = lib.mkDefault "org.kde.dolphin.desktop";
    };
    associations.added = {
      "inode/directory" = lib.mkDefault "org.kde.dolphin.desktop";
    };
  };
}
