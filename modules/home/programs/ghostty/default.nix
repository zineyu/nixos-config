{ ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 13;
      font-family = "Maple Mono NF CN";

      window-padding-x = 12;
      window-padding-y = 12;
      background-opacity = 1.0;
      background-blur-radius = 32;

      cursor-style = "bar";
      cursor-style-blink = true;

      scrollback-limit = 3023;

      mouse-hide-while-typing = true;
      copy-on-select = false;
      confirm-close-surface = false;
      app-notifications = "no-clipboard-copy,no-config-reload";

      unfocused-split-opacity = 0.7;
      unfocused-split-fill = "#44464f";

      gtk-titlebar = false;

      shell-integration = "detect";
      shell-integration-features = "cursor,sudo,title,no-cursor";
      keybind = [ "shift+enter=text:\\n" ];

      gtk-single-instance = true;

      theme = "catppuccin-macchiato.conf";
    };
  };

  xdg.configFile = {
    "ghostty/config-dankcolors".source = ./config/config-dankcolors;
    "ghostty/themes" = {
      source = ./config/themes;
      recursive = true;
    };
  };
}
