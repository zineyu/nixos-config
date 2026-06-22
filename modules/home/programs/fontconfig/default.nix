{ config, pkgs, ... }:

let
  storeLinks = import ../../../../lib/storeLinks.nix { inherit config; };
in
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
      ];
      monospace = [
        "Maple Mono NF CN"
        "Fira Code"
        "DejaVu Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    fira-code
    maple-mono.NF-CN
  ];

  xdg.configFile = {
    # Static dotfiles are linked from the Nix store.
    "fontconfig" = {
      source = storeLinks.mkInStore ./config;
      recursive = true;
    };

    # These files are provided by the host system's fontconfig package and
    # must not be copied into /nix/store, so we use an out-of-store symlink.
    "fontconfig/conf.d/10-sub-pixel-rgb.conf".source =
      storeLinks.mkOutOfStore "/usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf";

    "fontconfig/conf.d/50-user.conf".source =
      storeLinks.mkOutOfStore "/usr/share/fontconfig/conf.avail/50-user.conf";
  };
}
