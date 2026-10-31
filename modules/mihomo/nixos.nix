# mihomo（fake-IP TUN 代理）的系统级部分：NixOS（systemd 服务）。
# 配置与 nix-darwin 侧共用 ../config.yaml，代理凭据由 sops 注入。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  proxiesFile = config.sops.secrets.mihomo_proxies.path;

  # nixpkgs 的 services.mihomo 以 DynamicUser 运行，配置经 LoadCredential 放进
  # /run/credentials/mihomo.service（属主是该动态用户）。代理 provider 文件不能
  # 直接从 root-only 的 /run/secrets 读取，因此也作为 credential 一起挂载，
  # 路径固定，可在构建期写进配置。
  credentialsDir = "/run/credentials/mihomo.service";

  configFile = pkgs.writeText "mihomo-config.yaml" (
    lib.replaceStrings [ "@proxies_file@" ] [ "${credentialsDir}/providers.yaml" ] (
      builtins.readFile ./config.yaml
    )
  );
in
{
  sops.secrets.mihomo_proxies = {
    sopsFile = ../../secrets/mihomo.yaml;
    format = "binary";
  };

  services.mihomo = {
    enable = true;
    inherit configFile;
    # 授予 CAP_NET_ADMIN；TUN 本身仍由 config.yaml 的 tun.enable 打开。
    tunMode = true;
  };

  systemd.services.mihomo = {
    # mihomo 只允许 proxy-provider 从 SAFE_PATHS 读取文件。
    environment = {
      SAFE_PATHS = credentialsDir;
    };
    serviceConfig.LoadCredential = lib.mkForce [
      "config.yaml:${configFile}"
      "providers.yaml:${proxiesFile}"
    ];
  };
}
