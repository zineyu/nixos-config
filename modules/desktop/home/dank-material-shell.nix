{
  inputs,
  pkgs,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
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

  xdg.configFile = {
    "DankMaterialShell/settings.json".source = jsonFormat.generate "dms-settings.json" (
      import ./DankMaterialShell/settings.nix
    );
    "DankMaterialShell/zen.css".source = ./DankMaterialShell/zen.css;
  };
}
