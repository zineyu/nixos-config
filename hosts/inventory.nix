# Host Inventory（结构化主机注册表，见 ADR-0002 / ADR-0006 / ADR-0014 / ADR-0018）。
#
# attr key 即 hostname；每台主机声明三样东西，各占一个轴：
#   - system / kind      构建参数（用哪条构建路径）
#   - facts              机器**事实**：形态、GPU、显示器。必须写全，缺失求值期报错。
#                        形态（desktop/server/wsl）与 NVIDIA 由 facts 派生能力，
#                        因此**不在 tags 里重复声明**（写了会被 enum 拒绝）。
#   - tags               人的**选择**：要不要图形会话、要不要 docker/sshd/tailscale…
#   - userEnvironment    （可选）true 表示该 host 有 User Environment
#   - homeStateVersion   （可选）Home Manager 兼容版本，默认 "26.05"
#   - deploy             （可选）deploy-rs 远程部署元数据
#
# 这个文件是**唯一**的 host 差异来源：没有 import 列表，也没有"装哪些软件"的清单——
# program 自己决定需要什么能力。差异只走三条轴：缺席 → tags，程度 → zine.* knob，
# 事实 → facts。模块门控一律写 host.gates.<能力>，词表见 lib/host-tags.nix。
#
# 新增主机：
#   1. 在此注册条目（远程主机补 deploy 段，并在 .sops.yaml 配置密钥）；
#   2. 创建 hosts/<hostname>/default.nix，只写机器事实（引导器、硬件、系统服务参数）；
#   3. 需要用户环境时置 userEnvironment = true，覆盖写在 hosts/<hostname>/home.nix
#      （该文件可以不存在，也可以只写 zine.* knob）。
{
  tianxuan = {
    system = "x86_64-linux";
    kind = "nixos";
    homeStateVersion = "26.05";
    userEnvironment = true;

    facts = {
      form = "desktop";
      # Optimus 双显卡；PRIME offload 的 PCI bus id 是硬件事实，由 nvidia 模块读取。
      gpu = {
        vendors = [
          "intel"
          "nvidia"
        ];
        prime = {
          intelBusId = "PCI:66:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      # 实证来源：DMS 生成的 modules/desktop/home/niri/dms/outputs.kdl。
      # 输出布局由 DMS 在运行时维护，这里只记录事实，不据此生成 niri 配置。
      displays = [
        {
          output = "HDMI-A-1";
          resolution = "2560x1440";
          refresh = 144;
          scale = 1.0;
        }
        {
          output = "eDP-2";
          resolution = "2560x1440";
          refresh = 60;
          scale = 1.5;
        }
      ];
    };

    tags = [
      "gui"
      "docker"
      "sshd"
      "tailscale"
      "mihomo"
      "headscale-backup"
    ];
  };

  aliyun-01 = {
    system = "x86_64-linux";
    kind = "nixos";

    facts = {
      form = "server";
      gpu.vendors = [ ];
    };

    tags = [
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

    facts = {
      form = "laptop";
      gpu.vendors = [ "apple" ];
    };

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

    facts = {
      form = "wsl";
      gpu.vendors = [ ];
    };

    tags = [ ];
  };
}
