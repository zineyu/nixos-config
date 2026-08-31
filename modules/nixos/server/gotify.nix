{ config, ... }:
let
  domain = "gotify.zineyu.cn";
  port = 1245;
in
{
  # GOTIFY_DEFAULTUSER_PASS（初始管理员密码）通过 environmentFile 注入，不进入 Nix store。
  # gotify-server 使用 DynamicUser，但 EnvironmentFile 由 systemd（PID 1）读取，
  # 无需把 secret 授权给动态用户。
  sops.secrets.gotify = {
    sopsFile = ../../../secrets/aliyun-01.yaml;
    format = "yaml";
    mode = "0400";
    restartUnits = [ "gotify-server.service" ];
  };

  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_SERVER_PORT = port;
      # 仅通过 nginx 反代对外，不直接监听公网
      GOTIFY_SERVER_LISTENADDR = "127.0.0.1";
    };
    environmentFiles = [ config.sops.secrets.gotify.path ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        # /stream 的 WebSocket 需要 Upgrade 头
        proxyWebsockets = true;
      };
    };
  };
}
