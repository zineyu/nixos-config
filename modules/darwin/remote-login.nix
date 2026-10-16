{
  # 开启 macOS 自带的 SSH 服务（Remote Login），使 tailnet 成员可直连
  # macbook-air-01（见 docs/adr/0008-headscale-tailnet.md）。
  # nix-darwin 没有对应选项，直接操作系统 com.openssh.sshd LaunchDaemon；
  # zine 的公钥授权经 home/ssh.nix 写入 ~/.ssh/authorized_keys。
  system.activationScripts.postActivation.text = ''
    /bin/launchctl enable system/com.openssh.sshd 2>/dev/null || true
    /bin/launchctl bootstrap system /System/Library/LaunchDaemons/ssh.plist 2>/dev/null \
      || /bin/launchctl kickstart -k system/com.openssh.sshd 2>/dev/null || true
  '';
}
