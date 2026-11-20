{
  # Truly shared values across all hosts.
  git = {
    name = "zine yu";
    email = "zine.xlws@gmail.com";
  };

  # zine 的 SSH 公钥（OpenPGP auth 子钥 EF5F9046F933CFED，
  # 私钥经 gpg-agent 的 SSH 套接字提供，见 programs/misc/gnupg/）。
  # 非敏感元数据：各 host 用其授权 tailnet 内互信登录。
  ssh.zinePublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9FM2h9+ysNfpHf0p2714ZijVYCPJyjiRwhhrc0BDKe openpgp:0xF933CFED";

  # 机器事实（GPU bus id 之类）不在这里：它们属于 Host Inventory 的 facts 段
  # （hosts/inventory.nix），由 host.facts 注入模块（ADR-0018）。
}
