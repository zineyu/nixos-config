# 所有 NixOS host 无条件导入的模块树入口——广播-门控（broadcast-and-gate）的
# 广播侧。这里**不判断 host**：每棵子树的 default.nix 读 specialArgs.host，
# 自行决定是否生效（ADR-0014 / ADR-0018）。
#
#   子树                    生效条件
#   ./common                无条件（真基线）
#   ./server                host.form.server，整棵子树入口门控（lint-allow-imports-gate）
#   ../desktop/system       host.hasTag "gui"，整棵子树入口门控（lint-allow-imports-gate）
#   ./wsl.nix               host.platform.wsl
#   ./nvidia.nix            facts.gpu.vendors 含 nvidia
#   ../sshd.nix             host.profile.personal（跨平台叶子，自行门控）
#   ../tailscale/nixos.nix  host.profile.personal（跨平台叶子，自行门控）
#   ../mihomo/nixos.nix     host.platform.nixos && host.form.pc（跨平台叶子，自行门控）
{ ... }:
{
  imports = [
    ./common
    ./server
    ../desktop/system
    ./wsl.nix
    ./nvidia.nix
    ../sshd.nix
    ../tailscale/nixos.nix
    ../mihomo/nixos.nix
  ];
}
