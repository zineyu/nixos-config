{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      # nginx (vaultwarden, headscale) + ACME
      80
      443
    ];
    # Headscale 内嵌 STUN（NAT 打洞用，见 headscale.nix）
    allowedUDPPorts = [ 3478 ];
  };
}
