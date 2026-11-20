# 所有 nix-darwin host 无条件导入的模块树入口——Darwin 侧的广播（ADR-0018）。
#
#   子树                    生效条件（host.hasTag）
#   ./sops.nix              无条件（Darwin 的 secret 基座，programs 依赖其 age identity）
#   ./tailscale.nix         "tailscale"（自行门控）
#   ./remote-login.nix      "remote-login"（自行门控）
#   ../mihomo/darwin.nix    "mihomo"（跨平台叶子，自行门控）
{ ... }:
{
  imports = [
    ./sops.nix
    ./tailscale.nix
    ./remote-login.nix
    ../mihomo/darwin.nix
  ];
}
