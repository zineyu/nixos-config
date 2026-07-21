{
  # Truly shared values across all hosts.
  git = {
    name = "zine yu";
    email = "zine.xlws@gmail.com";
  };

  # Per-host values, keyed by hostname.
  hosts = {
    tianxuan = {
      hostname = "tianxuan";
      hardware = {
        intelBusId = "PCI:66:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    # Server hosts declare their hostname directly in hosts/<hostname>/configuration.nix.
  };
}
