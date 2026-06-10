{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.bash.enable {
    home.packages = [ pkgs.bash ];
  };
}
