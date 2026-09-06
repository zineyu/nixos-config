{ ... }:
{
  # 所有 NixOS host 共享的基础配置（./common）在此统一导入；
  # 具体 host 在 configuration.nix 中按需额外导入 ./desktop 或 ./server。
  imports = [ ./common ];
}
