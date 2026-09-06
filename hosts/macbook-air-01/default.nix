{ hostname, ... }:

let
  sharedNixSettings = import ../../lib/nix-settings.nix;
in
{
  # nix-darwin host entry for macbook-air-01.

  networking.hostName = hostname;

  users.users.zine = {
    name = "zine";
    home = "/Users/zine";
  };

  nix.settings = sharedNixSettings // {
    trusted-users = [ "zine" ];
  };

  nixpkgs.config.allowUnfree = true;

  # Let nix-darwin initialise its full environment before fish loads user
  # configuration. This includes the Home Manager per-user profile in PATH.
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
