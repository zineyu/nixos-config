{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.services.headscale-backup-pull;
in
{
  options.zine.services.headscale-backup-pull.enable =
    lib.mkEnableOption "从 aliyun-01 拉取 Headscale 状态快照";

  config = lib.mkIf cfg.enable {
    # Headscale 状态备份：每日从 aliyun-01 拉取快照目录（快照由服务器侧
    # headscale-backup timer 生成，见 modules/nixos/server/headscale.nix）。
    # SSH 走 modules/home/ssh 的 aliyun-01 alias（root@aliyun-01，复用 deploy 的密钥）。
    systemd.user.services.headscale-backup-pull = {
      Unit.Description = "Pull headscale state snapshot from aliyun-01";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "headscale-backup-pull" ''
            set -eu
            dest="$HOME/backups/headscale"
            mkdir -p "$dest"
            ${pkgs.rsync}/bin/rsync -a --delete -e ssh aliyun-01:/var/lib/headscale-backup/ "$dest/"
          ''
        );
      };
    };
    systemd.user.timers.headscale-backup-pull = {
      Unit.Description = "Daily headscale state backup pull";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
