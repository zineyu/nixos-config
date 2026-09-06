# Host inventory（结构化主机注册表，见 ADR-0002 / ADR-0006）。
#
# attr key 即 hostname；每台主机声明：
#   - system            构建平台（如 x86_64-linux / aarch64-darwin）
#   - kind              nixos | darwin，决定使用 mkSystem 还是 mkDarwinSystem
#   - homeStateVersion  （可选）Home Manager 兼容版本，默认 "26.05"
#   - deploy            （可选）deploy-rs 远程部署元数据
#
# 新增主机：
#   1. 创建 hosts/<hostname>/default.nix 作为系统模块入口；
#   2. 按需添加 configuration.nix / hardware-configuration.nix；
#   3. 在此注册主机条目（远程主机补 deploy 段，并在 .sops.yaml 配置密钥）。
{
  tianxuan = {
    system = "x86_64-linux";
    kind = "nixos";
    homeStateVersion = "26.05";
  };

  aliyun-01 = {
    system = "x86_64-linux";
    kind = "nixos";
    deploy = {
      enable = true;
      hostname = "aliyun-01";
      sshUser = "root";
    };
  };

  macbook-air-01 = {
    system = "aarch64-darwin";
    kind = "darwin";
    homeStateVersion = "26.05";
  };
}
