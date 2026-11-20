# Host Metadata：广播-门控模式（broadcast-and-gate）的唯一门控输入。
#
# lib/mkSystem.nix 把 Host Inventory 的条目经 specialArgs.host 注入**每一个**模块，
# 每个模块自行根据 host.gates 决定是否生效。host 因此不需要维护 import 列表，
# 也不需要写任何能力开关，更不需要一份"装哪些软件"的清单。
#
# Host Metadata 只有两个视图（ADR-0018）：
#   gates —— 布尔，对能力词表恒存在：chosen 部分来自 inventory 的 tags，
#            derived 部分由 facts 推导（形态、NVIDIA）。模块门控一律读它。
#   facts —— 值，机器的硬件事实：形态、GPU、显示器。inventory 必填。
# tags 不进入模块可见面：它是 inventory 的输入语法，模块只看推导结果。需要审计
# 来源时读这里的 zine.host.tags（本文件直接从 inventory 取，不经 specialArgs）。
#
# program 同理：模块自己判断"我需要什么能力"——需要图形会话就要求 gui，需要
# Wayland/nixpak 就要求 desktop，需要特定平台就查 host.kind。什么都不需要的程序
# 属于 User Environment 的基线，不门控。
#
# 门控代码一律读 specialArgs 的 `host`，不读 `config.zine.host`：`imports` 在模块
# 收集阶段求值，引用 `config` 会无限递归。`zine.host` 是同一份数据的**校验投影**，
# 不是第二份真相——它提供类型检查、`nix eval` 审计，以及跨能力的一致性断言。
{ host, lib, ... }:
let
  # 词表与 lib/mkSystem.nix 共享同一份来源，避免两处定义漂移。
  vocab = import ../lib/host-tags.nix;

  # Host Inventory 只在**校验与审计**时被读取：模块看不到 tags 这种"来源"，
  # 这样"按 tag 分支"在结构上就不可能（ADR-0018）。
  inventory = import ../hosts/inventory.nix;
  declaredTags = (inventory.${host.name} or { }).tags or [ ];

  factsType = lib.types.submodule {
    options = {
      form = lib.mkOption {
        type = lib.types.enum [
          "desktop"
          "laptop"
          "server"
          "wsl"
        ];
        description = "机器形态：派生 desktop / server / wsl 三个能力。";
      };

      gpu = lib.mkOption {
        type = lib.types.submodule {
          options = {
            vendors = lib.mkOption {
              type = lib.types.listOf (
                lib.types.enum [
                  "intel"
                  "amd"
                  "nvidia"
                  "apple"
                ]
              );
              default = [ ];
              description = "GPU 厂商；含 \"nvidia\" 即派生 nvidia 能力。";
            };
            prime = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    intelBusId = lib.mkOption {
                      type = lib.types.str;
                      description = "PRIME 输出端（Intel）PCI bus id。";
                    };
                    nvidiaBusId = lib.mkOption {
                      type = lib.types.str;
                      description = "PRIME 渲染端（NVIDIA）PCI bus id。";
                    };
                  };
                }
              );
              default = null;
              description = "Optimus 双显卡的 PCI bus id；非 NVIDIA 为 null。";
            };
          };
        };
        description = "图形硬件事实。";
      };

      displays = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              output = lib.mkOption {
                type = lib.types.str;
                description = "输出名，如 HDMI-A-1。";
              };
              resolution = lib.mkOption {
                type = lib.types.str;
                description = "分辨率，如 2560x1440。";
              };
              refresh = lib.mkOption {
                type = lib.types.int;
                description = "刷新率（Hz）。";
              };
              scale = lib.mkOption {
                type = lib.types.float;
                description = "逻辑缩放，如 1.0 / 1.5 / 2.0。";
              };
            };
          }
        );
        default = [ ];
        description = ''
          显示器事实，供"由事实派生参数"使用。没有消费者就不必填。
          注意输出布局由 DMS 在运行时维护（niri/dms/outputs.kdl），这里只记录事实。
        '';
      };
    };
  };
in
{
  options.zine.host = {
    name = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Host Inventory 的 attr 名，即 hostname。";
    };

    kind = lib.mkOption {
      type = lib.types.enum [
        "nixos"
        "darwin"
      ];
      readOnly = true;
      description = "构建路径：mkSystem 还是 mkDarwinSystem。";
    };

    system = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "构建平台，如 x86_64-linux。";
    };

    facts = lib.mkOption {
      type = factsType;
      readOnly = true;
      description = "机器事实：形态、GPU、显示器。派生能力与参数默认值的唯一输入。";
    };

    tags = lib.mkOption {
      type = lib.types.listOf (lib.types.enum vocab.chosen);
      readOnly = true;
      description = ''
        该 host 的**选择**：会话能力与系统能力。只能从 vocab.chosen 取——
        形态（desktop/server/wsl）与 nvidia 由 facts 派生，写在这里会被 enum 拒绝。
      '';
    };

    userEnvironment = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = ''
        该 host 是否有 User Environment。为 true 时 lib/mkSystem.nix 接入
        home-manager.users.zine，并导入 hosts/<hostname>/home.nix（若存在）。
      '';
    };

    gates = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      readOnly = true;
      description = ''
        能力词表的布尔投影：chosen（来自 tags）与 derived（来自 facts）的并集，
        对全词表恒存在，未命中为 false。模块用 host.gates.<能力> 门控（读的是
        specialArgs 里的同一对象），这里仅供
        `nix eval .#<host>.config.zine.host.gates` 审计。
      '';
    };
  };

  config = {
    zine.host = {
      inherit (host)
        name
        kind
        system
        facts
        gates
        ;
      tags = declaredTags;
      userEnvironment = host.userEnvironment or false;
    };

    assertions = [
      # 形态与构建路径一致：desktop / server / wsl 都是 NixOS 模块树。
      {
        assertion =
          !(lib.elem (host.facts.form) [
            "desktop"
            "server"
            "wsl"
          ])
          || host.kind == "nixos";
        message = "host `${host.name}`: facts.form = \"${host.facts.form}\" 只对 NixOS 有效。";
      }
      {
        assertion = !host.gates.desktop || host.gates.gui;
        message = "host `${host.name}`: facts.form = \"desktop\" 隐含 tag \"gui\"，两者必须同时成立。";
      }
      {
        assertion = !host.gates.gui || !host.gates.wsl;
        message = "host `${host.name}`: \"gui\" 与 form = \"wsl\" 互斥，WSL host 没有图形会话。";
      }
      {
        assertion = !host.gates.nvidia || host.kind == "nixos";
        message = "host `${host.name}`: facts.gpu.vendors 含 \"nvidia\" 只对 NixOS 有效，PRIME offload 由 NixOS 硬件模块提供。";
      }
      {
        assertion = !host.gates.nvidia || host.facts.gpu.prime != null;
        message = "host `${host.name}`: facts.gpu.vendors 含 \"nvidia\"，但没有写 facts.gpu.prime（intelBusId / nvidiaBusId）。";
      }
      {
        assertion = !host.gates."remote-login" || host.kind == "darwin";
        message = "host `${host.name}`: tag \"remote-login\" 只对 nix-darwin 有效，NixOS 用 tag \"sshd\"。";
      }
    ];
  };
}
