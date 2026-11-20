{
  host,
  lib,
  pkgs,
  ...
}:

let
  breezex-cursor = pkgs.callPackage ../breezex-cursor/package.nix { };
in
{
  config = lib.mkIf host.gates.gui {
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
