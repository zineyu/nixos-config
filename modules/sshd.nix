{ host, lib, ... }:
{
  config = lib.mkIf host.profile.personal {
    services.openssh = {
      enable = true;
      extraConfig = lib.mkAfter ''
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin prohibit-password

        Match Address *,!100.64.0.0/10,!fd7a:115c:a1e0::/48
          DenyUsers *
      '';
    };
  };
}
