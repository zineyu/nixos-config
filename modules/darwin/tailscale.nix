{
  config,
  lib,
  pkgs,
  ...
}:
let
  # 等价于 NixOS 模块的 tailscaled-autoconnect：nix-darwin 的 tailscale
  # 模块没有 authKeyFile，用 LaunchDaemon 在 NeedsLogin 时自动登录。
  # sops 渲染的 preauth key 就绪且网络可用后才执行；已登录则直接退出。
  tsAutoLogin = pkgs.writeShellScript "tailscale-autologin" ''
    set -eu

    while ! {
      [ -r "${config.sops.secrets.tailscale_auth_key.path}" ]
      /sbin/route -n get default >/dev/null 2>&1
    }; do
      /bin/sleep 5
    done

    # tailscaled 就绪前 status 会失败，轮询等待终态。
    for _ in $(seq 1 30); do
      state=$(tailscale status --json --peers=false 2>/dev/null | jq -r .BackendState 2>/dev/null || echo unknown)
      case "$state" in
        Running)
          exit 0
          ;;
        NeedsLogin | NeedsMachineAuth | Stopped)
          tailscale up \
            --login-server=https://hs.zineyu.cn \
            --auth-key "$(cat "${config.sops.secrets.tailscale_auth_key.path}")"
          exit 0
          ;;
        *)
          /bin/sleep 2
          ;;
      esac
    done
    echo "tailscaled did not reach a stable state in time" >&2
    exit 1
  '';
in
{
  # Darwin host 的 tailnet 接入（见 docs/adr/0008-headscale-tailnet.md）。
  # 与 NixOS 相同，使用共享 sops 文件中的可复用 preauth key 自动注册
  # （provisioning 见 modules/nixos/common/tailscale.nix 与 docs/secrets.md）。
  sops.secrets.tailscale_auth_key = {
    sopsFile = ../../secrets/tailscale.yaml;
    key = "preauth_key";
  };

  services.tailscale.enable = true;

  launchd.daemons.tailscale-autologin = {
    serviceConfig = {
      ProgramArguments = [ "${tsAutoLogin}" ];
      RunAtLoad = true;
      # 网络变化时重试（可自愈掉线/状态丢失），成功退出后不循环。
      KeepAlive = {
        NetworkState = true;
        SuccessfulExit = false;
      };
      ThrottleInterval = 30;
      EnvironmentVariables = {
        PATH = lib.concatStringsSep ":" [
          "${pkgs.tailscale}/bin"
          "${pkgs.jq}/bin"
          "/usr/sbin"
          "/sbin"
          "/usr/bin"
          "/bin"
        ];
      };
      StandardOutPath = "/var/log/tailscale-autologin.log";
      StandardErrorPath = "/var/log/tailscale-autologin.log";
    };
  };

  # nix-darwin 模块只为 ts.net 写 /etc/resolver；为自定义 MagicDNS
  # base_domain 补一条，使 *.ts.zineyu.cn 走 quad100 解析。
  environment.etc."resolver/ts.zineyu.cn" = {
    text = "nameserver 100.100.100.100";
    # tailscaled 可能自行创建/改写该文件，记录已知哈希以避免激活冲突。
    knownSha256Hashes = [
      "2c28f4fe3b4a958cd86b120e7eb799eee6976daa35b228c885f0630c55ef626c"
    ];
  };
}
