{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

  ];

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

  # Workaround: dbus-broker user unit reload hangs during deploy-rs activation,
  # causing the entire deployment to fail and roll back.
  # Force a restart instead of reload when the unit changes.
  systemd.user.services.dbus-broker = {
    serviceConfig = {
      X-ReloadIfChanged = lib.mkForce "false";
      ExecReload = lib.mkForce "";
      X-RestartIfChanged = lib.mkForce "true";
    };
  };

}
