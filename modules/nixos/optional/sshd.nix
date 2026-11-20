# OpenSSH 服务端。
#
# 广播-门控：被 modules/nixos/optional/default.nix 无条件导入，只有带 "sshd"
# tag 的 host 生效。这里没有 option：能力不可能与决定它的 metadata 漂移。
{ host, lib, ... }:
{
  config = lib.mkIf host.gates.sshd {
    # 仅密钥登录；授权的公钥在 common/users.nix 中声明（zine 的 OpenPGP auth
    # 子钥，vars.ssh.zinePublicKey），与是否开启 sshd 无关。
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
