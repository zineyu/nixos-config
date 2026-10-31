# 桌面环境的系统级部分（NixOS 模块）：greetd/niri/portal、音频、显卡、
# 输入法、nixpak overlay 与桌面软件清单。由使用 Wayland 桌面的 host 显式导入。
# 用户级部分见 modules/desktop/home/。
{ inputs, ... }:
{
  imports = [
    inputs.dank-greeter.nixosModules.default
    inputs.niri.nixosModules.niri
    inputs.aagl.nixosModules.default

    ./audio.nix
    ./desktop.nix
    ./graphics.nix
    ./input-method.nix
    ./networking.nix
    ./nixpak.nix
    ./packages.nix
    ./steam.nix
  ];
}
