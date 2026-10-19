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

  imports = [
    ../../modules/darwin/sops.nix
    ../../modules/darwin/tailscale.nix
    ../../modules/darwin/remote-login.nix
    ../../modules/darwin/mihomo.nix
  ];

  networking.hostName = hostname;

  system.primaryUser = "zine";

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

  # nix-homebrew bootstraps Homebrew itself. nix-darwin then installs
  # Karabiner through its official cask so the signed installer can register
  # the background services required by Karabiner 15.7 and later.
  nix-homebrew = {
    enable = true;
    user = "zine";
  };

  homebrew = {
    enable = true;
    user = "zine";
    brews = [
      # mas is required by homebrew.masApps to install Mac App Store apps.
      "mas"
    ];
    casks = [
      "karabiner-elements"
      "orbstack"
      "jordanbaird-ice"
      # RustDesk 客户端（双向互控，被控端由 App 自带的 LaunchDaemon 常驻；
      # nixpkgs 的 rustdesk-flutter 仅支持 linux）。
      # 首次打开需在本机授权：屏幕录制 + 辅助功能，并安装其服务。
      "rustdesk"
    ];
    # Xcode is only distributed through the Mac App Store. Requires zine to
    # be signed in to the App Store app before activation.
    masApps = {
      Xcode = 497799835;
    };
    onActivation.cleanup = "none";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
