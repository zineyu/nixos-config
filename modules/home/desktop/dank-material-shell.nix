{
  inputs,
  ...
}:

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
    "DankMaterialShell/settings.json".source = ./DankMaterialShell/settings.json;
    "DankMaterialShell/zen.css".source = ./DankMaterialShell/zen.css;
  };
}
