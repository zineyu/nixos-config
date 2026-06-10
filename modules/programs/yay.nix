{ df, ... }:

{
  xdg.configFile."yay" = {
    source = df "yay";
    recursive = true;
  };
}
