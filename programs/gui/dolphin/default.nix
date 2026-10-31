{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.dolphin;
in
{
  options.zine.programs.dolphin.enable = lib.mkEnableOption "Dolphin 文件管理器";

  config = lib.mkIf cfg.enable {
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
