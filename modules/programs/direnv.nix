{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.direnv.enable {
    home.packages = [ pkgs.direnv ];

    xdg.configFile."direnv" = {
      source = df "direnv";
      recursive = true;
    };
  };
}
