# 所有 nix-darwin host 无条件导入的模块树入口——Darwin 侧的广播（ADR-0018）。
#
#   子树                           生效条件
#   ./sops.nix                     无条件（Darwin 的 secret 基座，programs 依赖其 age identity）
#   ../shared/sshd.nix             host.profile.personal（跨平台叶子，自行门控）
#   ../shared/tailscale/darwin.nix host.profile.personal（跨平台叶子，自行门控）
#   ../shared/mihomo/darwin.nix    host.platform.darwin（跨平台叶子，自行门控）
{ ... }:
{
  imports = [
    ./sops.nix
    ../shared/sshd.nix
    ../shared/tailscale/darwin.nix
    ../shared/mihomo/darwin.nix
  ];
}
