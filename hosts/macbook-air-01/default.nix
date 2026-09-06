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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
