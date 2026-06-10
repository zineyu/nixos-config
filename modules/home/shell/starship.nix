{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}
