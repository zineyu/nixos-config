# 所有 NixOS host 无条件导入的模块树入口——广播-门控（broadcast-and-gate）的
# 广播侧。这里**不判断 host**：每棵子树的 default.nix 读 specialArgs.host，
# 自行决定是否生效。
#
#   子树                         生效条件（host.gates）
#   ./common                     无条件（真基线）
#   ./optional                   逐能力：各自比对自己的 gate
#   ./server                     "server"
#   ../desktop/system            "desktop"
#   ./wsl.nix                    "wsl"
#   ./nvidia.nix                 "nvidia"
#   ../mihomo/nixos.nix          "mihomo"（跨平台叶子，平台树负责挂载）
{ host, lib, ... }:
{
  imports = [
    ./common
    ./optional
    ./server
    ../desktop/system
    ./wsl.nix
    ./nvidia.nix
  ]
  ++ lib.optionals host.gates.mihomo [ ../mihomo/nixos.nix ];
}
