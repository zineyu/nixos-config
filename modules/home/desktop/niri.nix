{ pkgs, ... }:

let
  niriConfig = import ../../../lib/niri-config.nix {
    inherit pkgs;
    niriDir = ./niri;
  };

in

{
  xdg.configFile."niri/config.kdl" = {
    source = "${niriConfig}/config.kdl";
    force = true;
  };

  xdg.configFile."niri/dms" = {
    source = "${niriConfig}/dms";
    recursive = true;
    force = true;
  };
}
