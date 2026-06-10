{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.dank-material-shell.enable {
    xdg.configFile."DankMaterialShell" = {
      source = df "DankMaterialShell";
      recursive = true;
    };
  };
}
