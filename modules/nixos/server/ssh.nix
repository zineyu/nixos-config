{
  services.openssh = {
    enable = true;
    # 默认仅允许 root 使用密钥登录；若当前使用密码登录，请改为 "yes" 并尽快切到密钥
    settings.PermitRootLogin = "prohibit-password";
  };
}
