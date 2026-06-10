{ df, ... }:

{
  xdg.configFile."DankMaterialShell" = {
    source = df "DankMaterialShell";
    recursive = true;
  };
}
