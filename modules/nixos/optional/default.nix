# 可插拔的系统能力。每个模块**不声明 option**，而是用
# `lib.mkIf host.gates.<tag>` 直接门控（见 lib/host-tags.nix 与 ADR-0014），
# 因此 host 既不在 configuration.nix 里写开关，能力也无法与决定它的 metadata 漂移。
# 未命中 tag 时该模块不产生任何配置。
#
# 所有 NixOS host 都需要的共享基线在 ../common；无法用 tag 表达、必须整棵导入
# 的模块树（server、desktop/system）由 ../default.nix 广播，各自在入口门控。
{ extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;
}
