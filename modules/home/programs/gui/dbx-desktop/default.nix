{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.dbx-desktop;
in
{
  options.zine.programs.dbx-desktop.enable = lib.mkEnableOption "DBX Desktop";

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ../../../../../pkgs/dbx-desktop.nix { }) ];
  };
}
