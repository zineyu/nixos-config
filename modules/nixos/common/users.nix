{
  pkgs,
  vars,
  ...
}:

{
  users.users.zine = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "render"
    ];
    shell = pkgs.fish;
    # 所有 host（含 WSL）都信任 zine 的 OpenPGP auth 子钥；这是用户属性，
    # 与 host 是否带 "sshd" tag 无关。
    openssh.authorizedKeys.keys = [ vars.ssh.zinePublicKey ];
  };
}
