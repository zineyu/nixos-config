{ ... }:
let
  domain = "atuin.zineyu.cn";
  port = 8888;
in
{
  # 自托管 atuin shell 历史同步服务器。
  # 数据库复用 postgresql.nix 声明的实例（unix socket + peer 认证），
  # database.createLocally 默认会追加 atuin 用户与数据库。
  services.atuin = {
    enable = true;
    # TODO: 部署后注册首个账号（atuin register），然后改为 false 并重新部署
    openRegistration = false;
    # 仅通过 nginx 反代对外，不直接监听公网
    host = "127.0.0.1";
    inherit port;
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
