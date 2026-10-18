{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.cursor;
  breezex-cursor = pkgs.callPackage ../../../../../pkgs/breezex-cursor.nix { };
in
{
  options.zine.programs.cursor.enable = lib.mkEnableOption "BreezeX 光标主题";

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      enable = true;
      name = "BreezeX-Light";
      package = breezex-cursor;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
