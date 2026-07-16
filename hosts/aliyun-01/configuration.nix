{ ... }:
{
  imports = [
    # FIXME: 替换为服务器上 `nixos-generate-config` 的真实输出
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/server
  ];

  networking.hostName = "aliyun-01";

  time.timeZone = "Asia/Shanghai";

  # 如有需要，后续可覆盖 bootloader：
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/vda";

  # sops-nix 框架已就绪；流程见 docs/secrets.md。
  # 拿到 aliyun-01 的 age public key 后取消下面两行注释：
  # sops.defaultSopsFile = ./secrets/aliyun-01.yaml;
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  system.stateVersion = "26.05";
}
