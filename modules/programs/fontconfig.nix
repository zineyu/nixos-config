{ config, lib, df, mkInStore, mkOutOfStore, ... }:

{
  config = lib.mkIf config.programs.zine.fontconfig.enable {
    xdg.configFile = {
      # Static dotfiles are linked from the Nix store.
      "fontconfig" = {
        source = mkInStore (df "fontconfig");
        recursive = true;
      };

      # These files are provided by the host system's fontconfig package and
      # must not be copied into /nix/store, so we use an out-of-store symlink.
      "fontconfig/conf.d/10-sub-pixel-rgb.conf".source =
        mkOutOfStore "/usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf";

      "fontconfig/conf.d/50-user.conf".source =
        mkOutOfStore "/usr/share/fontconfig/conf.avail/50-user.conf";
    };
  };
}
