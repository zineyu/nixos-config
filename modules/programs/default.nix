{ config, lib, ... }:

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
    "yay"
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
  options.programs.zine = lib.listToAttrs (map mkProgramOption programNames);

  imports = map (name: ./. + "/${name}.nix") programNames;

  config._module.args = { inherit dotfiles df; } // storeLinks;
}
