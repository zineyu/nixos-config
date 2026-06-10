{ df, ... }:

{
  xdg.configFile."yazi" = {
    source = df "yazi";
    recursive = true;
  };
}
