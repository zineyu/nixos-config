{ config, ... }:
{
  # Headplane：headscale 的 Web 管理界面（节点/用户/API key/DNS 管理）。
  #
  # 暴露面：仅 tailnet 内可达。防火墙未放行 3000 端口，公网不可访问；
  # tailnet 成员经 trusted interface tailscale0 访问：
  #   http://aliyun-01.ts.zineyu.cn:3000/admin
  # tailnet 传输由 WireGuard 端到端加密，因此 HTTP 可接受（cookie_secure = false）。
  #
  # 登录方式：在浏览器中粘贴 headscale API key（建议存入 vaultwarden）：
  #   headscale apikeys create --expiration 8760h
  sops.secrets.headplane_cookie_secret = {
    sopsFile = ../../../secrets/aliyun-01.yaml;
    # headplane 以 headscale 用户运行（见 nixpkgs 模块）。
    owner = config.services.headscale.user;
    group = config.services.headscale.group;
    mode = "0400";
    restartUnits = [ "headplane.service" ];
  };

  services.headplane = {
    enable = true;
    settings.server = {
      host = "0.0.0.0";
      port = 3000;
      cookie_secret_path = config.sops.secrets.headplane_cookie_secret.path;
      cookie_secure = false;
      # API key 登录的会话有效期（默认仅 1 天）。
      cookie_max_age = 2592000;
    };
    # headscale.url / config_path / public_url 默认值已从
    # services.headscale 的配置派生，无需显式设置。
  };
}
