{ ... }:
{
  # modules/nixos 现在只包含所有 host 都需要的基础配置。
  # 具体 host 应在 configuration.nix 中额外 import ./common 与 ./desktop 或 ./server。
  imports = [ ./common ];
}
