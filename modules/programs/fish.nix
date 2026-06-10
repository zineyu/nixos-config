{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.fish.enable {
    home.packages = [ pkgs.fish ];

    xdg.configFile."fish" = {
      source = df "fish";
      recursive = true;
    };
  };
}
