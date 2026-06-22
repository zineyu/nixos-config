{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./fish/config.fish;
  };

  xdg.configFile = {
    "fish/completions" = {
      source = ./fish/completions;
      recursive = true;
    };
    "fish/conf.d" = {
      source = ./fish/conf.d;
      recursive = true;
    };
    "fish/functions" = {
      source = ./fish/functions;
      recursive = true;
    };
    "fish/themes" = {
      source = ./fish/themes;
      recursive = true;
    };
    "fish/fish_plugins".source = ./fish/fish_plugins;
    "fish/fish_variables".source = ./fish/fish_variables;
  };
}
