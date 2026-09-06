{ pkgs, ... }:

{
  gtk.enable = true;

  gtk.iconTheme = {
    package = pkgs.tela-icon-theme;
    name = "Tela";
  };
}
