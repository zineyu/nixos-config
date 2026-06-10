{ df, ... }:

{
  xdg.configFile."starship.toml".source = df "starship.toml";
}
