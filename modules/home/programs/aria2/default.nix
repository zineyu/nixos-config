{ pkgs, ... }:

{
  home.packages = [ pkgs.aria2 ];

  xdg.configFile."aria2/aria2.conf".source = ./aria2.conf;
}
