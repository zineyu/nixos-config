{ ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Steam and most games still ship 32-bit binaries, so 32-bit graphics
  # drivers are required. The NVIDIA module wires up the matching 32-bit
  # driver automatically when this is enabled.
  hardware.graphics.enable32Bit = true;
}
