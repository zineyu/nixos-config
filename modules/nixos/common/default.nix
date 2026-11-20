# 所有 NixOS host 无条件共享的基线配置。可插拔的系统能力见 ../optional。
{ extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;
}
