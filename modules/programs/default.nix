{ config, lib, ... }:

let
  dotfiles = ../../dotfiles;
  df = path: dotfiles + "/${path}";
  out = config.lib.file.mkOutOfStoreSymlink;
in
{
  _module.args = { inherit dotfiles df out; };

  imports = [
    ./bash.nix
    ./git.nix
    ./npm.nix

    ./aria2.nix
    ./dank-material-shell.nix
    ./direnv.nix
    ./fish.nix
    ./fontconfig.nix
    ./ghostty.nix
    ./jj.nix
    ./kitty.nix
    ./niri.nix
    ./nvim.nix
    ./starship.nix
    ./systemd.nix
    ./yay.nix
    ./yazi.nix
    ./zed.nix
    ./zellij.nix
  ];
}
