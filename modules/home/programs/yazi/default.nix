{ ... }:

{
  programs.yazi = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./config/yazi.toml);
    keymap = builtins.fromTOML (builtins.readFile ./config/keymap.toml);
    theme = builtins.fromTOML (builtins.readFile ./config/theme.toml);
  };
}
