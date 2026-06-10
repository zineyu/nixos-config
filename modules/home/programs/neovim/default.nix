{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      stylua
      tree-sitter
    ];
  };

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
