{
  config,
  lib,
  pkgs,
  ...
}:

{
  # 自托管 RustDesk 服务端：hbbs（ID 注册/打洞协调，21116 TCP+UDP）+
  # hbbr（中继，21117 TCP）。只服务 tailnet 客户端：
  # tailscale0 已是 trusted interface（modules/nixos/common/tailscale.nix），
  # 公网防火墙不新开端口。
  services.rustdesk-server = {
    enable = true;
    # 告知客户端 relay 地址；MagicDNS 名称（ADR-0005 已退役 pinned IP 模式）。
    signal.relayHosts = [ "aliyun-01.ts.zineyu.cn" ];
    relay.enable = true;
  };

  # hbbs 的 ed25519 密钥对经 sops 预置（而非首启随机生成），
  # 使客户端的 key（vars.rustdesk.publicKey）可以随仓库声明式分发，
  # 重建服务端后客户端无需重新配置。
  sops.secrets.rustdesk-id-ed25519 = {
    sopsFile = ../../../secrets/aliyun-01.yaml;
    # sops 文件内的键名用下划线（yaml key 习惯）。
    key = "rustdesk_id_ed25519";
    # 私钥只存 /run/secrets（默认），由 rustdesk-signal 的 preStart 安装到
    # hbbs 工作目录；模块的 StateDirectory（/var/lib/rustdesk）归属
    # rustdesk 动态用户，激活期直接落盘 ownership 会竞态。
  };

  systemd.services.rustdesk-signal.serviceConfig.ExecStartPre = lib.mkAfter [
    # 密钥默认仅 root 可读，而服务以 rustdesk 用户运行；
    # "+" 前缀使本步骤以 root 执行（systemd 特权前缀），再 chown 落盘。
    "+${pkgs.writeShellScript "rustdesk-signal-install-key" ''
      install -Dm600 -o rustdesk -g rustdesk \
        ${config.sops.secrets.rustdesk-id-ed25519.path} \
        /var/lib/rustdesk/id_ed25519
    ''}"
  ];
}
