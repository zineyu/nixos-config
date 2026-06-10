{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.zed.enable {
    xdg.configFile."zed" = {
      source = df "zed";
      recursive = true;
    };
  };
}
