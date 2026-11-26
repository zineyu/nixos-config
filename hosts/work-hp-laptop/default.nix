# Host module for the `work-hp-laptop` machine (NixOS-WSL).
#
# WSL 的差异全部由 platform = "wsl" 承载（modules/nixos/platform/wsl.nix）；user 级覆盖见
# ./home.nix（该文件目前为空模块）。
{ ... }:
{
  time.timeZone = "Asia/Shanghai";

  system.stateVersion = "26.05";
}
