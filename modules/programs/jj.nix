{ df, ... }:

{
  xdg.configFile."jj" = {
    source = df "jj";
    recursive = true;
  };
}
