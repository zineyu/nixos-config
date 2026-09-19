{ hostname, ... }:
{
  # Darwin host 的 sops-nix 基础配置。home/ssh.nix 等的 secret 依赖这里的
  # age identity（管理员 key 的 rootfs 副本，与 tianxuan 相同机制）。
  #
  # 首次启用前需要把管理员 age identity（位于
  # /Users/zine/.config/sops/age/keys.txt）复制到系统路径（见 docs/secrets.md）：
  #   sudo install -d -m 0700 /var/lib/sops-nix
  #   sudo install -m 0600 /Users/zine/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt
  sops = {
    defaultSopsFile = ../../secrets + "/${hostname}.yaml";
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [ ];
    };
  };
}
