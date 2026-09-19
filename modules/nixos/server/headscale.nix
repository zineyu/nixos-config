{ config, pkgs, ... }:
let
  domain = "hs.zineyu.cn";
  # MagicDNS base_domain 不能等于 server_url 的域；该域不需要公网解析，
  # 由节点上的 quad100 (100.100.100.100) 应答。
  baseDomain = "ts.zineyu.cn";
  port = 8085;
in
{
  # Headscale 自托管控制面（见 docs/adr/0008-headscale-tailnet.md）。
  #
  # 节点接入采用双重授权模型：
  #   - repo 管理的 host：sops 中的可复用 preauth key 自动注册
  #     （见 modules/nixos/common/tailscale.nix、modules/darwin/tailscale.nix）
  #   - 其余设备：客户端生成密钥对 + 服务端手动授权，无预共享密钥
  #     客户端: tailscale up --login-server=https://hs.zineyu.cn  （输出 mkey:xxx）
  #     服务端: headscale nodes register --user zine --key mkey:xxx
  #
  # 恢复 runbook（状态丢失时）：
  #   1. systemctl stop headscale
  #   2. 从 tianxuan 的 ~/backups/headscale/ 拷回 db.sqlite 与
  #      noise_private.key 到 /var/lib/headscale/（owner headscale:headscale，0600）
  #   3. systemctl start headscale；所有节点无需重新注册
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    inherit port;
    settings = {
      server_url = "https://${domain}";
      dns = {
        magic_dns = true;
        base_domain = baseDomain;
        # 全局上游 DNS（headscale 要求 MagicDNS 必须配置）：tailnet 域名走
        # MagicDNS，其余查询由客户端转发到国内公共解析。
        nameservers.global = [
          "223.5.5.5"
          "119.29.29.29"
        ];
      };
      derp = {
        server = {
          # 内嵌 DERP 中继（与 443 同端口，nginx 反代需支持 HTTP Upgrade），
          # 替代国内不可达的 Tailscale 公共 DERP。STUN 端口需在安全组放行。
          enabled = true;
          region_id = 900;
          region_code = "aliyun";
          region_name = "Aliyun";
          stun_listen_addr = "0.0.0.0:3478";
        };
        urls = [ ];
      };
      log.level = "warn";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      # DERP 与长轮询都依赖 HTTP Upgrade；长连接不应被缓冲或提前超时。
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_buffering off;
      '';
    };
  };

  # tianxuan 的备份 timer 通过 ssh（root@aliyun-01）rsync 拉取快照目录。
  environment.systemPackages = [ pkgs.rsync ];
  # tailnet 的唯一用户，幂等创建（用户已存在时跳过）。
  systemd.services.headscale-user-zine = {
    description = "Ensure headscale user 'zine' exists";
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # headscale CLI 即使非 TTY 也输出 ANSI 颜色码，不能直接 grep 表格；
      # 用 JSON 输出做精确匹配。
      if ! ${config.services.headscale.package}/bin/headscale users list -o json | grep -qE '"name": *"zine"'; then
        ${config.services.headscale.package}/bin/headscale users create zine
      fi
    '';
  };

  # 状态快照：sqlite 在线备份 + noise 私钥。tianxuan 每日拉取本目录
  # （见 home/tianxuan.nix 的 headscale-backup-pull 用户 timer）。
  systemd.services.headscale-backup = {
    description = "Snapshot headscale state (sqlite online backup + noise key)";
    after = [ "headscale.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -eu
      dest=/var/lib/headscale-backup
      install -d -m 0750 "$dest"
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/headscale/db.sqlite ".backup '$dest/db.sqlite'"
      install -m 0600 /var/lib/headscale/noise_private.key "$dest/noise_private.key"
    '';
  };
  systemd.timers.headscale-backup = {
    description = "Daily headscale state snapshot";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
