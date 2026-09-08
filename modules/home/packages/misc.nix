# 其他工具（下载、加密/密钥管理）。配置见 modules/home/programs/misc/ 与 home/ssh.nix。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs;
  squirrel = pkgs.callPackage ../../../pkgs/squirrel.nix { };
in
{
  options.zine.programs = {
    aria2.enable = lib.mkEnableOption "aria2 下载管理器";
    gpg.enable = lib.mkEnableOption "GnuPG";
    # The application is installed as a Homebrew cask by the Darwin host.
    karabiner-elements.enable = lib.mkEnableOption "Karabiner-Elements 用户配置";
    rime-ice.enable = lib.mkEnableOption "Rime Ice 雾凇拼音输入法";
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
      ]
      ++ lib.optionals cfg.rime-ice.enable [ rime-ice ]
      ++ lib.optionals (cfg.rime-ice.enable && pkgs.stdenv.hostPlatform.isDarwin) [ squirrel ];
  };
}
