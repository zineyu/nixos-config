# 所有 nix-darwin host 无条件导入的模块树入口——Darwin 侧的广播。
#
#   子树                生效条件（host.gates）
#   ./sops.nix          无条件（Darwin 的 secret 基座，programs 依赖其 age identity）
#   ./tailscale.nix     "tailscale"
#   ./remote-login.nix  "remote-login"
#   ../mihomo/darwin.nix "mihomo"（跨平台叶子，平台树负责挂载）
{ host, lib, ... }:
{
  imports = [ ./sops.nix ]
    ++ lib.optionals host.gates.tailscale [ ./tailscale.nix ]
    ++ lib.optionals host.gates."remote-login" [ ./remote-login.nix ]
    ++ lib.optionals host.gates.mihomo [ ../mihomo/darwin.nix ];
}
