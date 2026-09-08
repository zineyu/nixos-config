let
  shared = import ../../../lib/nix-settings.nix;
in
{
  nix.settings = shared // {
    trusted-users = [ "zine" ];
    auto-optimise-store = true;
  };

  # 每周自动 GC，删除 30 天前的旧 generation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # 限制 systemd journal 日志体积
  services.journald.settings.Journal = {
    SystemMaxUse = "1G";
  };

  nixpkgs.config.allowUnfree = true;
}
