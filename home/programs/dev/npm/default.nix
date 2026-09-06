{ config, ... }:

{
  programs.npm = {
    settings.prefix = "${config.home.homeDirectory}/.npm-global";
  };
}
