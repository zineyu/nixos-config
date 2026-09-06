# Home Manager 共享入口：NixOS 与 nix-darwin 主机共同使用。
# home.username / home.homeDirectory 由 home-manager 的 OS 模块自动从
# users.users.zine 派生（NixOS 为 /home/zine，darwin 为 /Users/zine），无需在此声明。
# Linux-only 的子树（desktop、programs/gui）通过 extraLibs.linuxOnly 做平台门控。
{ ... }:

{
  imports = [
    ./common.nix
    ./tools.nix
    ./shell
    ./desktop
    ./programs
    ./ssh.nix
  ];
}
