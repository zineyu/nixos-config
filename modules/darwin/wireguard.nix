{
  config,
  hostname,
  lib,
  pkgs,
  vars,
  ...
}:

# Darwin 主机的 WireGuard overlay 接入（对应 NixOS 侧 modules/nixos/common/wireguard.nix）。
#
# Darwin host 以 externalPeers 身份加入 10.77.0.0/24 中心辐射网络：
#   - 私钥经 sops-nix（darwinModules.sops）从 secrets/<hostname>.yaml 解密，
#     由 sops.templates 渲染为 /run/secrets/rendered/wireguard/wg0.conf，
#     私钥不进入 Nix store；
#   - wg-quick 由 LaunchDaemon 常驻拉起，使用用户态 wireguard-go 创建 utun 接口。
#
# 首次启用前需要把管理员 age identity（与 Linux 相同，位于
# /Users/zine/.config/sops/age/keys.txt）复制到系统路径（见 docs/secrets.md）：
#   sudo install -d -m 0700 /var/lib/sops-nix
#   sudo install -m 0600 /Users/zine/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt

let
  inherit (vars) wireguard;
  peer = wireguard.externalPeers.${hostname};
  hub = vars.hosts.${wireguard.hub}.wireguard;
  wgLauncher = pkgs.writeShellScript "wireguard-wg0-launcher" ''
    set -eu

    # launchd may start system daemons before the sops-rendered config, Wi-Fi
    # and the default route are ready. Wait here so wg-quick does not fail
    # during boot.
    while ! {
      [ -r "${config.sops.templates."wireguard/wg0.conf".path}" ]
      /sbin/route -n get default >/dev/null 2>&1
      /usr/bin/nc -z -G 3 223.5.5.5 53 >/dev/null 2>&1
    }; do
      /bin/sleep 5
    done

    # Idempotent start: clear any interface left behind by a previous run so
    # wg-quick always configures from a clean state (same idea as the NixOS
    # module's preSetup).
    wg-quick down "${config.sops.templates."wireguard/wg0.conf".path}" 2>/dev/null || true
    exec wg-quick up "${config.sops.templates."wireguard/wg0.conf".path}"
  '';
in
{
  sops = {
    defaultSopsFile = ../../secrets + "/${hostname}.yaml";
    age = {
      # 管理员 age identity 的 rootfs 副本（与 tianxuan 相同）；系统激活不依赖
      # 用户 home 中的 key，也不依赖 macOS 是否启用 Remote Login（SSH host key）。
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [ ];
    };

    secrets.wireguard_private_key = { };

    templates."wireguard/wg0.conf" = {
      mode = "0600";
      content = ''
        [Interface]
        PrivateKey = ${config.sops.placeholder.wireguard_private_key}
        Address = ${peer.address}/32

        [Peer]
        PublicKey = ${hub.publicKey}
        Endpoint = ${wireguard.endpoint}
        AllowedIPs = ${wireguard.subnet}
        PersistentKeepalive = 25
      '';
    };
  };

  launchd.daemons.wireguard-wg0 = {
    serviceConfig = {
      ProgramArguments = [ "${wgLauncher}" ];
      RunAtLoad = true;
      # wg-quick up is a oneshot: relaunch on network changes, but never loop
      # after a successful exit. Sleep/wake may drop the utun interface without
      # launchd noticing; run `sudo launchctl kickstart -k system/org.nixos.wireguard-wg0`
      # (or reconnect the network) to recover.
      KeepAlive = {
        NetworkState = true;
        SuccessfulExit = false;
      };
      ThrottleInterval = 30;
      # LaunchDaemons start with a minimal PATH. wg-quick needs wireguard-go
      # (userspace implementation on macOS) plus ifconfig/route in /usr/sbin.
      EnvironmentVariables = {
        PATH = lib.concatStringsSep ":" [
          "${pkgs.wireguard-tools}/bin"
          "${pkgs.wireguard-go}/bin"
          "/usr/sbin"
          "/sbin"
          "/usr/bin"
          "/bin"
        ];
      };
      StandardOutPath = "/var/log/wireguard-wg0.log";
      StandardErrorPath = "/var/log/wireguard-wg0.log";
    };
  };
}
