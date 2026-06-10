{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.npm.enable {
    home.packages = [ pkgs.nodejs ];

    home.file.".npmrc".source = df "npmrc";
  };
}
