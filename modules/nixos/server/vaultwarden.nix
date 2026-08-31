{ config, ... }:
let
  domain = "vault.zineyu.cn";
in
{
  sops.secrets.vaultwarden = {
    sopsFile = ../../../secrets/aliyun-01.yaml;
    format = "yaml";
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
    restartUnits = [ "vaultwarden.service" ];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    configureNginx = true;
    inherit domain;
    # ADMIN_TOKEN（argon2id PHC）通过 environmentFile 注入，不进入 Nix store
    environmentFile = config.sops.secrets.vaultwarden.path;
    config = {
      # 使用独立声明的 PostgreSQL 实例（见 postgresql.nix），
      # 通过 unix socket + peer 认证连接，无需密码
      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
      # TODO: 部署后注册首个账号，然后改为 false 并重新部署
      SIGNUPS_ALLOWED = false;
    };
  };

  systemd.services.vaultwarden = {
    after = [ "postgresql.target" ];
    requires = [ "postgresql.target" ];
  };

  # services.vaultwarden.configureNginx 只设置 forceSSL，ACME 证书需要单独声明
  services.nginx.virtualHosts.${domain}.enableACME = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@zineyu.com";
  };
}
