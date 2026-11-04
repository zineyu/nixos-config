{
  # Truly shared values across all hosts.
  git = {
    name = "zine yu";
    email = "zine.xlws@gmail.com";
  };

  # zine 的 SSH 公钥（OpenPGP auth 子钥 EF5F9046F933CFED，
  # 私钥经 gpg-agent 的 SSH 套接字提供，见 programs/misc/gnupg/）。
  # 非敏感元数据：各 host 用其授权 tailnet 内互信登录。
  ssh.zinePublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9FM2h9+ysNfpHf0p2714ZijVYCPJyjiRwhhrc0BDKe openpgp:0xF933CFED";

  # RustDesk 自托管服务端（hbbs，架于 aliyun-01，见 modules/nixos/server/rustdesk.nix）
  # 的 ed25519 公钥。客户端用其校验与 hbbs 的连接加密；私钥经 sops 预置到
  # /var/lib/rustdesk/id_ed25519。非敏感元数据。
  rustdesk.publicKey = "bY0wR0GnxC2CdWjbPK7fXwzz+b3TjJUIIESWgz4do0A=";

  # Per-host values, keyed by hostname.
  hosts = {
    tianxuan = {
      hardware = {
        intelBusId = "PCI:66:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    aliyun-01 = { };
  };
}
