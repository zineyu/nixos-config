{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.kitty.enable {
    xdg.configFile = {
      "kitty/current-theme.conf".source = df "kitty/current-theme.conf";
      "kitty/dank-tabs.conf".source = df "kitty/dank-tabs.conf";
      "kitty/dank-theme.conf".source = df "kitty/dank-theme.conf";
      "kitty/kitty.conf".source = df "kitty/kitty.conf";
      "kitty/scroll_mark.py".source = df "kitty/scroll_mark.py";
      "kitty/search.py".source = df "kitty/search.py";
      "kitty/themes" = {
        source = df "kitty/themes";
        recursive = true;
      };
    };
  };
}
