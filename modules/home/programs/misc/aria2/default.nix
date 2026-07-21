{ ... }:

{
  programs.aria2 = {
    enable = true;
    settings = {
      continue = true;
      dir = "/home/zine/Downloads";
      file-allocation = "falloc";
      log-level = "debug";
      max-connection-per-server = 4;
      max-concurrent-downloads = 3;
      max-overall-download-limit = 0;
      min-split-size = "5M";
      enable-http-pipelining = true;
      enable-rpc = true;
    };
  };
}
