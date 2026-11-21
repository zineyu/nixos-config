# 所有 NixOS host 无条件共享的基线配置。按 host 的标签生效的系统模块见 ../optional。
{ extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;
}
