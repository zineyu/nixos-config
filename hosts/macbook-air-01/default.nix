{
  hostname,
  pkgs,
  ...
}:

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

  # Run Mihomo as a root LaunchDaemon so configurations with TUN enabled can
  # create the network interface. The configuration itself remains user-owned.
  launchd.daemons.mihomo.serviceConfig = {
    ProgramArguments = [
      "${pkgs.mihomo}/bin/mihomo"
      "-d"
      "/Users/zine/.config/mihomo"
      "-f"
      "/Users/zine/.config/mihomo/config.yaml"
    ];
    KeepAlive = true;
    RunAtLoad = true;
    ProcessType = "Background";
    StandardOutPath = "/var/log/mihomo.log";
    StandardErrorPath = "/var/log/mihomo.log";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
