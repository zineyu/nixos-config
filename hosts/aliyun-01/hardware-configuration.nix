{
  lib,
  ...
}:
{
  # 占位符硬件配置：请替换为远程服务器 `nixos-generate-config` 的真实输出。
  # 当前仅用于本地构建验证，不可直接部署。
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
