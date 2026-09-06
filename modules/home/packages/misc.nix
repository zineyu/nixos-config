# 其他工具（下载、加密/密钥管理）。配置见 programs/misc/ 与 ssh.nix。
{ pkgs, ... }:

{
  programs = {
    aria2.enable = true;
    gpg.enable = true;
    ssh.enable = true;
  };

  home.packages = with pkgs; [
    age
    sops
  ];
}
