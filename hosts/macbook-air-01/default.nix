{ hostname, vars, ... }:

let
  sharedNixSettings = import ../../lib/nix-settings.nix;
in
{
  # nix-darwin host entry for macbook-air-01.

  networking.hostName = vars.hosts.${hostname}.hostname;

  users.users.zine = {
    name = "zine";
    home = "/Users/zine";
  };

  home-manager.users.zine = import ../../modules/home;

  nix.settings = sharedNixSettings // {
    trusted-users = [ "zine" ];
  };

  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
