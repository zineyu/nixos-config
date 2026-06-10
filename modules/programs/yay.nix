{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.yay.enable {
    xdg.configFile."yay" = {
      source = df "yay";
      recursive = true;
    };
  };
}
