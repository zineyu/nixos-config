{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      # nginx (vaultwarden) + ACME
      80
      443
    ];
  };
}
