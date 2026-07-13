{
  config,
  pkgs,
  lib,
  ...
}:

let
  breezex-cursor = pkgs.callPackage ./breezex-cursor.nix { };
in
{
  home.packages = [ breezex-cursor ];

  home.pointerCursor = {
    enable = true;
    name = "BreezeX-Light";
    package = breezex-cursor;
    size = 24;
    x11.enable = true;
    gtk.enable = true;
  };
}
