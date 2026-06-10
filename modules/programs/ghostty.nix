{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.ghostty.enable {
    home.packages = [ pkgs.ghostty ];

    xdg.configFile."ghostty" = {
      source = df "ghostty";
      recursive = true;
    };
  };
}
