# mihomo 代理内核的用户级部分：CLI 本体。
#
# 系统级部分在 modules/mihomo/（NixOS 用 systemd，nix-darwin 用 launchd），两者读
# 同一份 config.yaml。同一个能力 tag 在 programs/ 与 modules/ 两侧都必须有 owner，
# 否则用户级那一半只能靠 Machine File 手装——macbook-air-01 之前就是这样
# （`home.packages = [ pkgs.mihomo ]`），那是 ADR-0018 要消灭的泄漏。
{
  host,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf host.gates.mihomo {
    home.packages = [ pkgs.mihomo ];
  };
}
