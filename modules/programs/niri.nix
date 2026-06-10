{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.niri.enable {
    home.packages = [ pkgs.niri ];

    xdg.configFile."niri/dms" = {
      source = df "niri/dms";
      recursive = true;
      force = true;
    };
  };
}
