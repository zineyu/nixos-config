{ config, lib, pkgs, ... }:

let
  dotfiles = ../../dotfiles;
  df = path: dotfiles + "/${path}";
  storeLinks = import ../../lib/storeLinks.nix { inherit config; };

  programNames = [
    "aria2"
    "bash"
    "dank-material-shell"
    "direnv"
    "fish"
    "fontconfig"
    "ghostty"
    "git"
    "jj"
    "kitty"
    "niri"
    "npm"
    "nvim"
    "starship"
    "systemd"
    "yazi"
    "zed"
    "zellij"
  ];

  mkProgramOption = name: {
    inherit name;
    value = {
      enable = lib.mkEnableOption "zine's ${name} dotfiles" // {
        default = true;
      };
    };
  };
in
{
  options.programs.zine = lib.listToAttrs (map mkProgramOption programNames) // {
    dev-tools.enable = lib.mkEnableOption "zine's dev-tools packages" // {
      default = true;
    };
  };

  imports = map (name: ./. + "/${name}.nix") programNames;

  config = {
    _module.args = { inherit dotfiles df; } // storeLinks;

    home.packages = lib.mkIf config.programs.zine.dev-tools.enable (with pkgs; [
      curl
      fd
      fzf
      gcc
      gnumake
      ripgrep
      stylua
      tree-sitter
      unzip
    ]);
  };
}
