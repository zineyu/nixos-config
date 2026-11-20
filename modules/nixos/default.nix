# 所有 NixOS host 无条件导入的模块树入口——广播-门控（broadcast-and-gate）的
# 广播侧。这里**不判断 host**：每棵子树的 default.nix 读 specialArgs.host，
# 自行决定是否生效（ADR-0014 / ADR-0018）。
#
#   子树                    生效条件
#   ./common                无条件（真基线）
#   ./optional              逐能力：各自比对自己的 host.hasTag
#   ./server                host.form.server，整棵子树入口门控（lint-allow-imports-gate）
#   ../desktop/system       host.form.pc，整棵子树入口门控（lint-allow-imports-gate）
#   ./wsl.nix               host.platform.wsl
#   ./nvidia.nix            host.hasTag "nvidia"
#   ../mihomo/nixos.nix     host.hasTag "mihomo"（跨平台叶子，自行门控）
{ ... }:
{
  imports = [
    ./common
    ./optional
    ./server
    ../desktop/system
    ./wsl.nix
    ./nvidia.nix
    ../mihomo/nixos.nix
  ];
}
