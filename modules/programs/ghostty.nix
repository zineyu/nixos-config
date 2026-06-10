{ df, ... }:

{
  xdg.configFile."ghostty" = {
    source = df "ghostty";
    recursive = true;
  };
}
