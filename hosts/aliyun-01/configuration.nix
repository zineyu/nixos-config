{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server
  ];

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
  networking.hostName = "aliyun-01";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGgIF/RgUlwjhijDzN9pzFhKNaFCZZ/fTo+CVrBmgu7 openpgp:0xD075FA27"
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
