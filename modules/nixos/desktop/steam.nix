{ ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    # 桌面防火墙已在 desktop/networking.nix 中整体禁用，
    # 因此 remotePlay/dedicatedServer/localNetworkGameTransfers 的
    # openFirewall 选项不生效，此处不再重复开放端口。
  };

  # Steam and most games still ship 32-bit binaries, so 32-bit graphics
  # drivers are required. The NVIDIA module wires up the matching 32-bit
  # driver automatically when this is enabled.
  hardware.graphics.enable32Bit = true;
}
