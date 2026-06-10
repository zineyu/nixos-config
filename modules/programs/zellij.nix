{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.zellij.enable {
    xdg.configFile."zellij" = {
      source = df "zellij";
      recursive = true;
    };
  };
}
