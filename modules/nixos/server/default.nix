# 常驻服务器模块树（headscale、nginx、postgresql、vaultwarden 等）。
# 广播-门控：被所有 NixOS host 导入，只有带 "server" tag 的 host 生效。
{ extraLibs, host, lib, ... }:
{
  imports = lib.optionals host.gates.server (extraLibs.scanPaths ./.);
}
