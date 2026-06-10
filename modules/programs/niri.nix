{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.niri.enable {
    xdg.configFile."niri/dms" = {
      source = df "niri/dms";
      recursive = true;
      force = true;
    };
  };
}
