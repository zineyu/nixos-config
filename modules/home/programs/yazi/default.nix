{ pkgs, ... }:

let
  # Catppuccin Macchiato syntax theme for yazi previews, referenced by
  # syntect_theme in theme.nix. Source: catppuccin/bat.
  catppuccin-macchiato-tmTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme";
    name = "Catppuccin-macchiato.tmTheme";
    hash = "sha256-EQCQ9lW5cOVp2C+zeAwWF2m1m6I0wpDQA5wejEm7WgY=";
  };
in
{
  programs.yazi = {
    enable = true;
    # Converted from the previous TOML files; each file is verified
    # deep-equal to its TOML source (builtins.fromTOML == import).
    settings = import ./settings.nix;
    keymap = import ./keymap.nix;
    theme = import ./theme.nix;
  };

  xdg.configFile."yazi/Catppuccin-macchiato.tmTheme".source = catppuccin-macchiato-tmTheme;
}
