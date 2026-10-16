{
  config,
  vars,
  ...
}:
{
  # 本机（桌面）解密并生成 SSH alias 配置。
  # secrets/ssh-hosts.yaml 里只放 host -> 真实 IP/域名的映射，
  # 仓库里 deploy-rs 仍然只保留非敏感别名。
  #
  # 各 host 的公钥授权：写入 ~/.ssh/authorized_keys（0644 非他人可写，
  # 满足 sshd StrictModes），私钥侧由 gpg-agent SSH 套接字提供。
  home.file.".ssh/authorized_keys".text = "${vars.ssh.zinePublicKey}\n";

  sops.secrets.aliyun-01 = {
    sopsFile = ../secrets/ssh-hosts.yaml;
  };

  # jumpserver 登录私钥，解密后直接落到 ~/.ssh/ 下（SSH 要求 0600）。
  sops.secrets."yzyang-jumpserver.pem" = {
    sopsFile = ../secrets/ssh-hosts.yaml;
    key = "yzyang-jumpserver-pem";
    path = "${config.home.homeDirectory}/.ssh/yzyang-jumpserver.pem";
    mode = "0600";
  };

  sops.templates.ssh-hosts = {
    content = ''
      Host aliyun-01
        HostName ${config.sops.placeholder.aliyun-01}
        User root

      Host jumpserver.alaxiaoyou.com
        HostName jumpserver.alaxiaoyou.com
        User yzyang
        Port 2222
        IdentityFile ${config.sops.secrets."yzyang-jumpserver.pem".path}
        IdentitiesOnly yes
        HostKeyAlgorithms +ssh-rsa
        PubkeyAcceptedKeyTypes +ssh-rsa
    '';
  };

  # ~/.ssh/config 已由 home-manager（programs.ssh）生成，
  # 这里通过 Include 引入 sops-nix 渲染后的真实主机配置，
  # 避免直接对只读 store symlink 写入。
  programs.ssh.settings."*" = { };
  # tailnet 成员别名：走 MagicDNS 名称直连（+.ts.zineyu.cn 的解析
  # 见 docs/adr/0008-headscale-tailnet.md）。StrictHostKeyChecking=accept-new
  # 使脚本化场景（备份 rsync 等）首次连接不交互。
  programs.ssh.extraConfig = ''
    Include ${config.sops.templates.ssh-hosts.path}

    Host tianxuan
      HostName tianxuan.ts.zineyu.cn
      User zine

    Host macbook-air-01
      HostName macbook-air-01.ts.zineyu.cn
      User zine

    Host aliyun-01-ts
      HostName aliyun-01.ts.zineyu.cn
      User root

    Host tianxuan macbook-air-01 aliyun-01-ts
      StrictHostKeyChecking accept-new
      # 弱网/休眠环境下及时探测连接死亡，避免终端挂死在假死连接上。
      ServerAliveInterval 30
      ServerAliveCountMax 3
  '';
}
