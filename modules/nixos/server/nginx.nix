{ config, ... }:
{
  # vaultwarden 的 nginx 虚拟主机与 ACME 证书。
  # services.vaultwarden.configureNginx 只设置 forceSSL，ACME 证书需要单独声明。
  services.nginx.virtualHosts.${config.services.vaultwarden.domain}.enableACME = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@zineyu.com";
  };
}
