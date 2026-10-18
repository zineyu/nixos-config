{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.aria2;
in
{
  options.zine.programs.aria2.enable = lib.mkEnableOption "aria2 下载管理器";

  config = lib.mkIf cfg.enable {
    programs.aria2 = {
      enable = true;
      settings = {
        continue = true;
        dir = "${config.home.homeDirectory}/Downloads";
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
  };
}
