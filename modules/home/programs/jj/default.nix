{ ... }:

{
  programs.jujutsu.enable = true;

  xdg.configFile."jj/config.toml".source = ./config.toml;
}
