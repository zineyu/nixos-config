{ config, lib, pkgs, df, ... }:

{
  config = lib.mkIf config.programs.zine.nvim.enable {
    home.packages = [ pkgs.neovim ];

    xdg.configFile."nvim" = {
      source = df "nvim";
      recursive = true;
    };
  };
}
