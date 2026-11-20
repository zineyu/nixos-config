# Host Inventory（结构化主机注册表，见 ADR-0002 / ADR-0006 / ADR-0014 / ADR-0015）。
#
# attr key 即 hostname；每台主机声明：
#   - system            构建平台（如 x86_64-linux / aarch64-darwin）
#   - kind              nixos | darwin，决定使用 mkSystem 还是 mkDarwinSystem
#   - tags              机器形态 / 会话能力 / 系统能力：模块全部被广播，由它门控
#   - userEnvironment   （可选）true 表示该 host 有 User Environment
#   - homeStateVersion  （可选）Home Manager 兼容版本，默认 "26.05"
#   - deploy            （可选）deploy-rs 远程部署元数据
#
# 这个文件是**唯一**的 host 差异来源：新增/删除能力只改 tags，没有 import 列表，
# 也没有"装哪些软件"的清单——program 自己决定需要什么能力。
# tag 词表登记在 lib/host-tags.nix（模块门控写 host.gates.<tag>）。
#
# 新增主机：
#   1. 在此注册条目（远程主机补 deploy 段，并在 .sops.yaml 配置密钥）；
#   2. 创建 hosts/<hostname>/default.nix，只写机器事实（引导器、硬件、系统服务参数）；
#   3. 需要用户环境时另建 hosts/<hostname>/home.nix，并置 userEnvironment = true。
{
  tianxuan = {
    system = "x86_64-linux";
    kind = "nixos";
    homeStateVersion = "26.05";
    userEnvironment = true;
    tags = [
      "desktop"
      "gui"
      "docker"
      "sshd"
      "tailscale"
      "mihomo"
      "nvidia"
      "headscale-backup"
    ];
  };

  aliyun-01 = {
    system = "x86_64-linux";
    kind = "nixos";
    tags = [
      "server"
      "docker"
      "sshd"
      "tailscale"
    ];
    # 常驻服务器没有 User Environment（没有 hosts/aliyun-01/home.nix）。
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
    userEnvironment = true;
    tags = [
      "gui"
      "tailscale"
      "mihomo"
      "remote-login"
    ];
  };

  work-hp-laptop = {
    system = "x86_64-linux";
    kind = "nixos";
    homeStateVersion = "26.05";
    userEnvironment = true;
    tags = [ "wsl" ];
  };
}
