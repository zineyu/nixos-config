{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.ghostty.enable {
    xdg.configFile."ghostty" = {
      source = df "ghostty";
      recursive = true;
    };
  };
}
