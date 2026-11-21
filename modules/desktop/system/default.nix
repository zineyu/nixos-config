# 桌面环境的系统级部分（NixOS 模块）：greetd/niri/portal、音频、蓝牙、显卡、
# 输入法、nixpak overlay 与桌面软件清单。
#
# 广播-门控：被 modules/nixos/default.nix 无条件导入，只有带 "gui" 标签的 host
# 才真正拉入第三方模块与下面的文件。第三方模块（dank-greeter、niri、aagl）
# 的断言与 option 无法在模块内部关闭，因此必须整棵按 gate 导入，而不是逐文件门控
# （ADR-0018 允许树入口门控，理由见下一行的 lint 豁免）。
# 用户级部分见 modules/desktop/home/。
#
# lint-allow-imports-gate: 第三方模块（dank-greeter / niri / aagl）的断言与 option
# 无法在模块体内关闭，只能在入口整棵按 gate 导入。
{
  host,
  inputs,
  lib,
  ...
}:
{
  imports = lib.optionals (host.hasTag "gui") [
    inputs.dank-greeter.nixosModules.default
    inputs.niri.nixosModules.niri
    inputs.aagl.nixosModules.default

    ./audio.nix
    ./bluetooth.nix
    ./desktop.nix
    ./graphics.nix
    ./input-method.nix
    ./networking.nix
    ./nixpak.nix
    ./packages.nix
    ./steam.nix
  ];
}
