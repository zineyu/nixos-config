# 常驻服务器模块树（headscale、nginx、postgresql、vaultwarden 等）。
# 广播-门控：被所有 NixOS host 导入，只有 facts.form = "server" 的 host 生效。
#
# lint-allow-imports-gate: scanPaths 子树作为一个整体门控；叶子模块（nginx、
# postgresql 等）互相依赖同一组 server 选项，逐叶子门控只会把同一个 gate 抄 12 遍。
{
  extraLibs,
  host,
  lib,
  ...
}:
{
  imports = lib.optionals host.gates.server (extraLibs.scanPaths ./.);
}
