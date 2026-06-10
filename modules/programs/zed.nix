{ df, ... }:

{
  xdg.configFile."zed" = {
    source = df "zed";
    recursive = true;
  };
}
