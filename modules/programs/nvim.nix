{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.nvim.enable {
    xdg.configFile."nvim" = {
      source = df "nvim";
      recursive = true;
    };
  };
}
