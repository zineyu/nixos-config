{ df, out, ... }:

{
  xdg.configFile = {
    "fontconfig" = {
      source = df "fontconfig";
      recursive = true;
    };

    "fontconfig/conf.d/10-sub-pixel-rgb.conf".source =
      out "/usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf";

    "fontconfig/conf.d/50-user.conf".source =
      out "/usr/share/fontconfig/conf.avail/50-user.conf";
  };
}
