# 所有 NixOS host 无条件共享的基线配置。按 host 的标签或轴生效的系统模块见
# modules/nixos/ 的其余子树（`server/`、`desktop/`、`hardware/`、`platform/`）。
{ extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;
}
