{ pkgs, inputs, ... }:

let
  niriConfig = import ../../../lib/niri-config.nix {
    niriDir = ./niri;
    inherit (pkgs) lib;
  };

in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableClipboardPaste = true;

    systemd.enable = true;

    niri = {
      enableSpawn = false;
      enableKeybinds = false;
      includes.enable = false;
    };
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    config = niriConfig;
  };

  xdg.configFile."niri/dms" = {
    source = ./niri/dms;
    recursive = true;
    force = true;
  };
}
