{ config, pkgs, ... }:

let
  storeLinks = import ../../../../lib/storeLinks.nix { inherit config; };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # Do not write Home Manager's generated init.lua into ~/.config/nvim;
    # we manage the whole nvim directory as an out-of-store symlink below.
    sideloadInitLua = true;
    extraPackages = with pkgs; [
      lua-language-server
    ];
  };

  # Symlink to the working-tree config directory so edits take effect without
  # re-running nixos-rebuild. See lib/storeLinks.nix.
  xdg.configFile."nvim".source =
    storeLinks.mkOutOfStoreDotfiles "modules/home/programs/neovim/config";
}
