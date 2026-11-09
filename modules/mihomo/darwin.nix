# mihomo（fake-IP TUN 代理）的系统级部分：nix-darwin（launchd LaunchDaemon）。
# 配置与 NixOS 侧共用 ../config.yaml，代理凭据由 sops 注入。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # 运行时状态目录（cache.db、geodata、ruleset 缓存），root 所有：
  # 配置文件已由仓库管理，用户不会再就地编辑它。
  stateDir = "/var/lib/mihomo";

  # 代理凭据由 sops 解密（secrets/mihomo.yaml，binary 格式）；其余配置
  # （DNS、fake-ip-filter、规则）与 NixOS 共用 ../config.yaml（ADR-0008）。
  proxiesFile = config.sops.secrets.mihomo_proxies.path;

  configFile = pkgs.writeText "mihomo-config.yaml" (
    lib.replaceStrings [ "@proxies_file@" ] [ proxiesFile ] (builtins.readFile ./config.yaml)
  );

  launcher = pkgs.writeShellScript "mihomo-launcher" ''
    set -eu

    # LaunchDaemon 可能在 Wi-Fi、默认路由与 sops secret 就绪前启动，先等待。
    while ! {
      [ -r "${proxiesFile}" ]
      /sbin/route -n get default >/dev/null 2>&1
      /usr/bin/nc -z -G 3 223.5.5.5 53 >/dev/null 2>&1
    }; do
      /bin/sleep 5
    done

    exec ${pkgs.mihomo}/bin/mihomo \
      -d ${stateDir} \
      -f ${configFile}
  '';
in
{
  sops.secrets.mihomo_proxies = {
    sopsFile = ../../secrets/mihomo.yaml;
    format = "binary";
  };

  system.activationScripts.mihomo.text = ''
    install -d -m 0700 ${stateDir}
  '';

  # TUN 需要 root，因此以系统 LaunchDaemon 运行。
  #
  # 可执行文件必须经 `command` 交付，不能直接写
  # `serviceConfig.ProgramArguments`。nix-darwin 只对 `command` 注入
  # `/bin/wait4path /nix/store` 包装；直接写 ProgramArguments 会让 plist
  # 指向 /nix/store 内的脚本，而开机时 launchd 启动本 job 的时刻早于
  # /nix 卷挂载完成的时刻。launchd 找不到该文件即判定初始化失败并置为
  # service inactive，此后 KeepAlive 不再触发重试。
  launchd.daemons.mihomo.command = "${launcher}";

  launchd.daemons.mihomo.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    ThrottleInterval = 30;
    ProcessType = "Background";
    # mihomo 只允许 proxy-provider 读取受信目录内的文件。
    EnvironmentVariables.SAFE_PATHS = lib.dirOf proxiesFile;
    StandardOutPath = "/var/log/mihomo.log";
    StandardErrorPath = "/var/log/mihomo.log";
  };
}
