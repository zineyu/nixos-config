{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.aria2.enable {
    home.packages = [ pkgs.aria2 ];
  };
}
