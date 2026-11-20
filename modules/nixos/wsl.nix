# NixOS-WSL：复用 Windows 提供的内核，因此没有任何 boot.kernelPackages 设置。
#
# 广播-门控：被 modules/nixos/default.nix 无条件导入，只有带 "wsl" tag 的 host
# 才拉入 nixos-wsl 模块与 ./wsl-config.nix。
#
# WSL 专属配置必须与 nixos-wsl 模块同时导入：`wsl.*` 选项由该模块声明，若在
# 非 WSL host 上无条件定义 `wsl.*`（哪怕包在 lib.mkIf false 里），module system
# 仍会因 option 不存在而在求值期报错。所以设置拆到 wsl-config.nix，随模块一起
# 条件导入，而不是用 mkIf 门控。
{
  host,
  inputs,
  lib,
  ...
}:
let
  wsl = host.gates.wsl;
in
{
  imports = lib.optionals wsl [
    inputs.nixos-wsl.nixosModules.default
    ./wsl-config.nix
  ];
}
