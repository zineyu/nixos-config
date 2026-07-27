{
  # Truly shared values across all hosts.
  git = {
    name = "zine yu";
    email = "zine.xlws@gmail.com";
  };

  wireguard = {
    subnet = "10.77.0.0/24";
    endpoint = "wg.zineyu.cn:51820";
    listenPort = 51820;
    hub = "aliyun-01";

    externalPeers.xiaomi15 = {
      hostname = "xiaomi15";
      address = "10.77.0.3";
      publicKey = "XMV7aLiGXWVEyC8yUXL2+Ehqi16AD7bgBIzYQkvDVjs=";
    };
  };

  # Per-host values, keyed by hostname.
  hosts = {
    tianxuan = {
      hostname = "tianxuan";
      hardware = {
        intelBusId = "PCI:66:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      wireguard = {
        address = "10.77.0.2";
        publicKey = "UHkGehewGqfHHEesHb3XE31ca0EJkpOpbr5kgAlEym0=";
        role = "spoke";
      };
    };

    aliyun-01 = {
      hostname = "aliyun-01";
      wireguard = {
        address = "10.77.0.1";
        publicKey = "+4ZqSxhDULH87sxT0UC4x9bWRi9WymtAZ8cfBcQkQgI=";
        role = "hub";
      };
    };
  };
}
