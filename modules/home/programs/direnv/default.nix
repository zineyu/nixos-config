{ ... }:

{
  programs.direnv.enable = true;

  xdg.configFile."direnv/direnv.toml".source = ./direnv.toml;
}
