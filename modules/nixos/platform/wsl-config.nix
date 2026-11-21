# NixOS-WSL 专属设置。
#
# 只在 modules/nixos/platform/wsl.nix 命中 platform = "wsl" 时与 nixos-wsl 模块一起导入，因此
# `wsl.*` 选项总是有声明（原因见 wsl.nix 的注释）。
{ lib, ... }:
{
  wsl = {
    enable = true;
    defaultUser = "zine";
  };

  # WSL 无需物理 TTY：禁用 getty@ 模板与 autovt@tty1，防止任何模块拉起 tty1。
  systemd.services."getty@".enable = lib.mkForce false;
  systemd.services."autovt@tty1".enable = lib.mkForce false;
}
