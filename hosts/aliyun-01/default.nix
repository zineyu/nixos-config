# Host module for the `aliyun-01` machine（常驻服务器）。
#
# 服务器模块树与 Docker/sshd/Tailscale 由 hosts/inventory.nix 的 tags 门控；本文件
# 只写机器事实、服务参数、secret 接线与部署 workaround。该 host 没有
# User Environment（未置 userEnvironment），因此没有 ./home.nix。
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # 物理服务器使用最新 mainline 内核；内核/引导属于主机属性。
  boot.kernelPackages = pkgs.linuxPackages_latest;

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.luogo_checkin = {
      sopsFile = ../../secrets/aliyun-01.yaml;
      format = "yaml";
      owner = "luogo_checkin";
      group = "luogo_checkin";
      mode = "0400";
    };
  };

  services.luogo_checkin = {
    enable = true;
    environmentFile = config.sops.secrets.luogo_checkin.path;
  };

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  # Server hostname is declared directly here instead of via vars/.
  networking.hostName = "aliyun-01";
  networking.domain = "";
  users.users.root.openssh.authorizedKeys.keys = [
    vars.ssh.zinePublicKey
  ];
  system.stateVersion = "26.11";

  # Workaround: dbus-broker (system and user) reloads/restarts during deploy-rs
  # activation break the D-Bus bus and cause the deployment to fail. Ignore all
  # unit changes at switch time; the bus will be updated on the next reboot.
  systemd.services.dbus-broker = {
    reloadIfChanged = lib.mkForce false;
    restartIfChanged = lib.mkForce false;
    stopIfChanged = lib.mkForce false;
    serviceConfig = {
      ExecReload = lib.mkForce "";
    };
  };

  systemd.user.services.dbus-broker = {
    reloadIfChanged = lib.mkForce false;
    restartIfChanged = lib.mkForce false;
    stopIfChanged = lib.mkForce false;
    serviceConfig = {
      ExecReload = lib.mkForce "";
    };
  };
}
