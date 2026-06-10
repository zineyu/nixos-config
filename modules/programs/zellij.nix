{ df, ... }:

{
  xdg.configFile."zellij" = {
    source = df "zellij";
    recursive = true;
  };
}
