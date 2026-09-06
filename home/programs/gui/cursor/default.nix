{
  pkgs,
  ...
}:

let
  breezex-cursor = pkgs.callPackage ../../../../pkgs/breezex-cursor.nix { };
in
{
  home.pointerCursor = {
    enable = true;
    name = "BreezeX-Light";
    package = breezex-cursor;
    size = 24;
    x11.enable = true;
    gtk.enable = true;
  };
}
