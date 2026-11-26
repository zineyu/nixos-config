{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zine.programs.kitty;
  kittyConfig = relPath: ./config/${relPath};
in
{
  options.zine.programs.kitty.fontSize = lib.mkOption {
    type = lib.types.float;
    default = 14.0;
    description = ''
      字号。默认 14；设备差异只在 hosts/<hostname>/home.nix 里写成
      `zine.programs.kitty.fontSize = 12.0;`（ADR-0018 的程度轴）。
    '';
  };

  config = lib.mkIf (host.hasTag "gui") {
    programs.kitty = {
      enable = true;

      font = {
        name = "Maple Mono NF CN";
        size = cfg.fontSize;
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
  };
}
