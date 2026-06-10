{ ... }:

{
  programs.fish = {
    enable = true;
  };

  xdg.configFile."fish" = {
    source = ./fish;
    recursive = true;
  };
}
