{ df, ... }:

{
  xdg.configFile."fish" = {
    source = df "fish";
    recursive = true;
  };
}
