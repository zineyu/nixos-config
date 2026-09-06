# 其他工具（下载、加密/密钥管理）。配置见 home/programs/misc/ 与 home/ssh.nix。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs;
in
{
  options.zine.programs = {
    aria2.enable = lib.mkEnableOption "aria2 下载管理器";
    gpg.enable = lib.mkEnableOption "GnuPG";
    ssh.enable = lib.mkEnableOption "SSH 客户端配置";
    sops.enable = lib.mkEnableOption "sops/age 秘密管理工具";
  };

  config = {
    programs = {
      aria2.enable = cfg.aria2.enable;
      gpg.enable = cfg.gpg.enable;
      ssh.enable = cfg.ssh.enable;
    };

    home.packages =
      with pkgs;
      lib.optionals cfg.sops.enable [
        age
        sops
      ];
  };
}
