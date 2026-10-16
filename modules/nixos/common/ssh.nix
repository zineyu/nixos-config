{ vars, ... }:
{
  # 所有 NixOS host 开启 sshd，使 tailnet 成员可互相直连
  # （tianxuan <-> aliyun-01，见 docs/adr/0008-headscale-tailnet.md）。
  # 与 server/ssh.nix 相同的 posture：仅密钥登录。
  # zine 使用 OpenPGP auth 子钥（vars.ssh.zinePublicKey，gpg-agent 提供私钥）。
  #
  # 暴露面说明：aliyun-01 防火墙仅放行 22/80/443（公网 SSH 作为管理回退，
  # 见 ADR-0008）；桌面防火墙整体关闭，sshd 与机上 dev server 一样
  # 仅靠 LAN/NAT 隔离，tailnet 侧则因 tailscale0 为 trusted interface 而互信。
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.zine.openssh.authorizedKeys.keys = [ vars.ssh.zinePublicKey ];
}
