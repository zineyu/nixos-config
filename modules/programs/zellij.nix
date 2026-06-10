{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.zellij.enable {
    home.packages = [ pkgs.zellij ];

    xdg.configFile."zellij" = {
      source = df "zellij";
      recursive = true;
    };
  };
}
