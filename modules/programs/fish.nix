{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.fish.enable {
    xdg.configFile."fish" = {
      source = df "fish";
      recursive = true;
    };
  };
}
