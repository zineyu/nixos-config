{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.jj.enable {
    xdg.configFile."jj" = {
      source = df "jj";
      recursive = true;
    };
  };
}
