{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.breezex-cursor;
in
{
  options.zine.programs.breezex-cursor.enable = lib.mkEnableOption "BreezeX 光标主题包";

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
