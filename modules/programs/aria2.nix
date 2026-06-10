{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.aria2.enable {
    xdg.configFile."aria2" = {
      source = df "aria2";
      recursive = true;
    };
  };
}
