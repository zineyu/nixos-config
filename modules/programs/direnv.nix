{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.direnv.enable {
    xdg.configFile."direnv" = {
      source = df "direnv";
      recursive = true;
    };
  };
}
