{ config, ... }:

{
  # atuin 加密密钥由 sops-nix 解密（secrets/atuin.yaml，zine_desktop 身份），
  # 软链到 atuin 的数据目录（Linux/macOS 均为 ~/.local/share/atuin/key）。
  # 密钥不进入 Nix store；各机器登录同一账号即可共享同步历史。
  sops.secrets.atuin_key = {
    sopsFile = ../../../../../secrets/atuin.yaml;
    mode = "0400";
  };

  programs.atuin = {
    enableFishIntegration = true;
    settings = {
      # 自托管同步服务器（aliyun-01，见 modules/nixos/server/atuin.nix）
      sync_address = "https://atuin.zineyu.cn";
      filter_mode = "session";
      keymap_mode = "vim-insert";
    };
  };

  home.file.".local/share/atuin/key".source =
    config.lib.file.mkOutOfStoreSymlink config.sops.secrets.atuin_key.path;
}
