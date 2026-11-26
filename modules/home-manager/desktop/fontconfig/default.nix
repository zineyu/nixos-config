{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK SC"
        "DejaVu Sans"
        "Roboto"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
        "DejaVu Serif"
      ];
      monospace = [
        "Maple Mono NF CN"
        "DejaVu Sans Mono"
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  xdg.configFile = {
    "fontconfig" = {
      source = ./config;
      recursive = true;
    };

    # 这两份 conf.avail 来自 nixpkgs 的 fontconfig 包：系统里没有
    # /usr/share/fontconfig（NixOS 不提供 /usr/share），链接进 store 后
    # 随字体配置一起切换，不再依赖宿主机文件。
    "fontconfig/conf.d/10-sub-pixel-rgb.conf".source =
      "${pkgs.fontconfig}/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf";

    "fontconfig/conf.d/50-user.conf".source =
      "${pkgs.fontconfig}/share/fontconfig/conf.avail/50-user.conf";
  };
}
