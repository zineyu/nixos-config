{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.starship.enable {
    home.packages = [ pkgs.starship ];

    xdg.configFile."starship.toml".source = df "starship.toml";
  };
}
