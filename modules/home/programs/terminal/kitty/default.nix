{ config, ... }:

let
  storeLinks = import ../../../../../lib/storeLinks.nix { inherit config; };
  kittyConfig =
    relPath: storeLinks.mkOutOfStoreDotfiles "modules/home/programs/terminal/kitty/config/${relPath}";
in
{
  programs.kitty = {
    enable = true;

    font = {
      name = "Maple Mono NF CN";
      size = 12.0;
    };

    settings = {
      cursor_shape = "beam";
      cursor_trail = 1;
      window_margin_width = 5;
      confirm_os_window_close = 0;
      shell = "fish";
      term = "xterm-256color";
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";

      "ctrl+f" =
        "launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id";
      "kitty_mod+f" =
        "launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id";

      page_up = "scroll_page_up";
      page_down = "scroll_page_down";

      "ctrl+plus" = "change_font_size all +1";
      "ctrl+equal" = "change_font_size all +1";
      "ctrl+kp_add" = "change_font_size all +1";
      "ctrl+minus" = "change_font_size all -1";
      "ctrl+underscore" = "change_font_size all -1";
      "ctrl+kp_subtract" = "change_font_size all -1";
      "ctrl+0" = "change_font_size all 0";
      "ctrl+kp_0" = "change_font_size all 0";
    };

    extraConfig = ''
      # BEGIN_KITTY_THEME
      # Catppuccin-Frappe
      include current-theme.conf
      # END_KITTY_THEME
    '';
  };

  xdg.configFile = {
    "kitty/current-theme.conf".source = kittyConfig "current-theme.conf";
    "kitty/dank-tabs.conf".source = kittyConfig "dank-tabs.conf";
    "kitty/dank-theme.conf".source = kittyConfig "dank-theme.conf";
    "kitty/search.py".source = kittyConfig "search.py";
    "kitty/scroll_mark.py".source = kittyConfig "scroll_mark.py";
    "kitty/themes".source = kittyConfig "themes";
  };
}
