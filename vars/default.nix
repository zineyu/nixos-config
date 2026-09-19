{
  # Truly shared values across all hosts.
  git = {
    name = "zine yu";
    email = "zine.xlws@gmail.com";
  };

  # Per-host values, keyed by hostname.
  hosts = {
    tianxuan = {
      hardware = {
        intelBusId = "PCI:66:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    aliyun-01 = { };
  };
}
