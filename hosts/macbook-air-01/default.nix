{
  hostname,
  pkgs,
  ...
}:

let
  sharedNixSettings = import ../../lib/nix-settings.nix;
  mihomoConfigDir = "/Users/zine/.config/mihomo";
  mihomoConfigFile = "${mihomoConfigDir}/config.yaml";
  mihomoLauncher = pkgs.writeShellScript "mihomo-launcher" ''
    set -eu

    # launchd may start system daemons before Wi-Fi and the default route are
    # ready. Wait here so Mihomo does not fail while downloading geodata.
    while ! {
      [ -r "${mihomoConfigFile}" ]
      /sbin/route -n get default >/dev/null 2>&1
      /usr/bin/nc -z -G 3 223.5.5.5 53 >/dev/null 2>&1
    }; do
      /bin/sleep 5
    done

    exec ${pkgs.mihomo}/bin/mihomo \
      -d "${mihomoConfigDir}" \
      -f "${mihomoConfigFile}"
  '';
in
{
  # nix-darwin host entry for macbook-air-01.

  networking.hostName = hostname;

  users.knownUsers = [ "zine" ];

  users.users.zine = {
    name = "zine";
    uid = 501;
    home = "/Users/zine";
    shell = pkgs.fish;
  };

  nix.settings = sharedNixSettings // {
    trusted-users = [ "zine" ];
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = [ pkgs.maple-mono.NF-CN ];

  # Let nix-darwin initialise its full environment before fish loads user
  # configuration. This includes the Home Manager per-user profile in PATH.
  programs.fish.enable = true;

  # Run Mihomo as a root LaunchDaemon so configurations with TUN enabled can
  # create the network interface. The configuration itself remains user-owned.
  launchd.daemons.mihomo.serviceConfig = {
    ProgramArguments = [
      "${mihomoLauncher}"
    ];
    KeepAlive = true;
    RunAtLoad = true;
    ThrottleInterval = 30;
    ProcessType = "Background";
    StandardOutPath = "/var/log/mihomo.log";
    StandardErrorPath = "/var/log/mihomo.log";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
