{ ... }:
{
  # 所有 NixOS host 共享的基础配置（./common）在此统一导入；
  # 具体 host 在 configuration.nix 中按需额外导入 ./server，桌面机再额外导入
  # modules/desktop/system（见 hosts/tianxuan/configuration.nix）。
  imports = [ ./common ];
}
