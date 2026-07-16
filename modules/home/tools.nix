{ pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    fd
    fzf
    gcc
    gnumake
    ripgrep
    stylua
    tree-sitter
    unzip

    bat
    btop
    eza
    fastfetch
    jq
    just
    ncdu
    wl-clipboard
  ];
}
