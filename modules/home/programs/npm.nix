{ pkgs, ... }:

{
  home.packages = [ pkgs.nodejs ];

  home.file.".npmrc".source = ./npmrc;
}
