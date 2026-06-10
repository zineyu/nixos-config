{ df, ... }:

{
  xdg.configFile."aria2" = {
    source = df "aria2";
    recursive = true;
  };
}
