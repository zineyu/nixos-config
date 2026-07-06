{ username, pkgs, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

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
