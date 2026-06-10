{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.starship.enable {
    xdg.configFile."starship.toml".source = df "starship.toml";
  };
}
