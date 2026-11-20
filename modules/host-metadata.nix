# Host Metadata：广播-门控模式（broadcast-and-gate）的唯一门控输入。
#
# lib/mkSystem.nix 把 Host Inventory 的条目经 specialArgs.host 注入**每一个**模块，
# 每个模块自行根据 host.gates（host.tags 的布尔投影）决定是否生效。host 因此不需要
# 维护 import 列表，也不需要写任何能力开关，更不需要一份"装哪些软件"的清单。
#
# program 同理：模块自己判断"我需要什么能力"——需要图形会话就要求 gui，需要
# Wayland/nixpak 就要求 desktop，需要特定平台就查 host.kind。什么都不需要的程序
# 属于 User Environment 的基线，不门控。
#
# 门控代码一律读 specialArgs 的 `host`，不读 `config.zine.host`：`imports` 在模块
# 收集阶段求值，引用 `config` 会无限递归。`zine.host` 是同一份数据的**校验投影**，
# 不是第二份真相——它提供类型检查（未知 tag 在求值期即报错）、可 `nix eval` 审计，
# 以及跨 tag 的一致性断言。
{ host, lib, ... }:
let
  # 词表与 lib/mkSystem.nix 共享同一份来源，避免两处定义漂移。
  knownTags = import ../lib/host-tags.nix;

  tags = host.tags or [ ];
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

    tags = lib.mkOption {
      type = lib.types.listOf (lib.types.enum knownTags);
      default = [ ];
      readOnly = true;
      description = ''
        该 host 的机器形态、会话能力与系统能力。模块树与 program 全部被广播，
        是否生效只由这里决定。新增 tag 必须同时在 lib/host-tags.nix 中登记。
      '';
    };

    userEnvironment = lib.mkOption {
      type = lib.types.bool;
      default = false;
      readOnly = true;
      description = ''
        该 host 是否有 User Environment。为 true 时 lib/mkSystem.nix 接入
        home-manager.users.zine 并导入 hosts/<hostname>/home.nix。
      '';
    };

    gates = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      readOnly = true;
      description = ''
        tags 的布尔投影：词表内每个 tag 都有一个条目，未声明为 false。模块用
        host.gates.<tag> 门控（读的是 specialArgs 里的同一对象），这里仅供
        `nix eval .#<host>.config.zine.host.gates` 审计。
      '';
    };
  };

  config = {
    zine.host = {
      inherit (host) name kind system;
      inherit tags;
      inherit (host) gates;
      userEnvironment = host.userEnvironment or false;
    };

    assertions = [
      {
        assertion =
          !(host.userEnvironment or false)
          || builtins.pathExists (../hosts + "/${host.name}/home.nix");
        message = "host `${host.name}`: userEnvironment = true，但 hosts/${host.name}/home.nix 不存在。";
      }
      {
        assertion = !(lib.elem "desktop" tags) || host.kind == "nixos";
        message = "host `${host.name}`: tag \"desktop\" 只对 NixOS 有效，modules/desktop/system 是 NixOS 模块树。";
      }
      {
        assertion = !(lib.elem "server" tags) || host.kind == "nixos";
        message = "host `${host.name}`: tag \"server\" 只对 NixOS 有效，modules/nixos/server 是 NixOS 模块树。";
      }
      {
        assertion = !(lib.elem "wsl" tags) || host.kind == "nixos";
        message = "host `${host.name}`: tag \"wsl\" 只对 NixOS 有效。";
      }
      {
        assertion = !(lib.elem "gui" tags) || !(lib.elem "wsl" tags);
        message = "host `${host.name}`: \"gui\" 与 \"wsl\" 互斥，WSL host 不声明图形会话。";
      }
      {
        assertion = !(lib.elem "nvidia" tags) || host.kind == "nixos";
        message = "host `${host.name}`: tag \"nvidia\" 只对 NixOS 有效，PRIME offload 由 NixOS 硬件模块提供。";
      }
      {
        assertion = !(lib.elem "remote-login" tags) || host.kind == "darwin";
        message = "host `${host.name}`: tag \"remote-login\" 只对 nix-darwin 有效，NixOS 用 tag \"sshd\"。";
      }
      {
        assertion = !(lib.elem "desktop" tags) || !(lib.elem "server" tags);
        message = "host `${host.name}`: \"desktop\" 与 \"server\" 互斥，一个 host 只能有一种机器形态。";
      }
      {
        assertion = !(lib.elem "desktop" tags) || lib.elem "gui" tags;
        message = "host `${host.name}`: tag \"desktop\" 隐含 \"gui\"，两者必须同时声明。";
      }
    ];
  };
}
