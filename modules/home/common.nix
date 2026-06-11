{ username, pkgs, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

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
  ];
}
