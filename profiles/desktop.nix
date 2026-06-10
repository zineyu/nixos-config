{ pkgs, inputs, ... }:

let
  niriConfig = import ../modules/lib/niri-config.nix {
    niriDir = ../dotfiles/niri;
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

    systemd.enable = false;

    niri = {
      enableSpawn = true;
      enableKeybinds = false;
      includes.enable = false;
    };
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    config = niriConfig;
  };
}
