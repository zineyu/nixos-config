{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.yazi.enable {
    home.packages = [ pkgs.yazi ];

    xdg.configFile."yazi" = {
      source = df "yazi";
      recursive = true;
    };
  };
}
