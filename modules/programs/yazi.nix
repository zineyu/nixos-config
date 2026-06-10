{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.yazi.enable {
    xdg.configFile."yazi" = {
      source = df "yazi";
      recursive = true;
    };
  };
}
