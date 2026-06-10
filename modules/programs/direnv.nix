{ df, ... }:

{
  xdg.configFile."direnv" = {
    source = df "direnv";
    recursive = true;
  };
}
