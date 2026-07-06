{ pkgs, ... }:

let
  niriConfig = import ../../../lib/niri-config.nix {
    niriDir = ./niri;
    inherit (pkgs) lib;
  };

in
{
  programs.niri = {
    config = niriConfig;
  };

  xdg.configFile."niri/dms" = {
    source = ./niri/dms;
    recursive = true;
    force = true;
  };
}
