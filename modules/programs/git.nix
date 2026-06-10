{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.git.enable {
    home.packages = [ pkgs.git ];

    home.file.".gitconfig".source = df "gitconfig";
  };
}
