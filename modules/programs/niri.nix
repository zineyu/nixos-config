{ df, ... }:

{
  xdg.configFile."niri/dms" = {
    source = df "niri/dms";
    recursive = true;
    force = true;
  };
}
