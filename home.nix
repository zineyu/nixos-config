{
  pkgs,
  config,
  inputs,
  ...
}:
let
  niriConfig = import ./modules/lib/niri-config.nix {
    niriDir = ./dotfiles/niri;
    inherit (pkgs) lib;
  };
in
{
  imports = [
    ./modules/programs
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
  ];
  home.username = "zine";
  home.homeDirectory = "/home/zine";

  # Keep this value at the release used for your first Home Manager install.
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableClipboardPaste = true;

    systemd.enable = false;

    niri = {
      enableSpawn = true;
      enableKeybinds = false;
      includes.enable = false;
    };
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    config = niriConfig;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

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
