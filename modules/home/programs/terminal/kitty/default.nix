{
  config,
  lib,
  pkgs,
  ...
}:

let
  storeLinks = import ../../../../../lib/storeLinks.nix { inherit config; };
  kittyConfig =
    relPath: storeLinks.mkOutOfStoreDotfiles "modules/home/programs/terminal/kitty/config/${relPath}";
in
{
  programs.kitty = {

    font = {
      name = "Maple Mono NF CN";
      size = lib.mkDefault 14.0;
    };

    themeFile = "Catppuccin-Macchiato";

    settings = {
      cursor_shape = "beam";
      cursor_trail = 1;
      window_margin_width = 5;
      confirm_os_window_close = 0;
      shell = "${config.programs.fish.package}/bin/fish";
      term = "xterm-256color";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      # Send both Option keys as Alt so Zellij's Alt-based bindings work on macOS.
      macos_option_as_alt = "both";
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
  };

  xdg.configFile = {
    "kitty/dank-tabs.conf".source = kittyConfig "dank-tabs.conf";
    "kitty/dank-theme.conf".source = kittyConfig "dank-theme.conf";
    "kitty/search.py".source = kittyConfig "search.py";
    "kitty/scroll_mark.py".source = kittyConfig "scroll_mark.py";
  };
}
