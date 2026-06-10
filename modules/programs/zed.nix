{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.zed.enable {
    home.packages = [ pkgs.zed-editor ];

    xdg.configFile."zed" = {
      source = df "zed";
      recursive = true;
    };
  };
}
