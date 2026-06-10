{ df, ... }:

{
  xdg.configFile."nvim" = {
    source = df "nvim";
    recursive = true;
  };
}
