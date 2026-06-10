{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    curl
    fd
    fzf
    gcc
    git
    gnumake
    ripgrep
    stylua
    tree-sitter
    unzip
  ];
}
