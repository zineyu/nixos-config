{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.jj.enable {
    home.packages = [ pkgs.jujutsu ];

    xdg.configFile."jj" = {
      source = df "jj";
      recursive = true;
    };
  };
}
