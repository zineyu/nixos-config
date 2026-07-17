{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.luogo_checkin;

  luogo_checkin = pkgs.buildGoModule {
    pname = "luogo_checkin";
    version = "unstable-2025-12-18";

    src = pkgs.fetchFromGitHub {
      owner = "zineyu";
      repo = "luogo_checkin";
      rev = "9f813a5105e1d90f66c297154bacfbf1ec4f569c";
      hash = "sha256-nfPpj2Yr5Z5L65zu6UWHY3ePSERiQsWv5LCMy2cvUYs=";
    };

    vendorHash = "sha256-9q451BDi0QCa0+YZLa3m2ITlWV/gCqQTf24qlqZnOFQ=";

    meta = {
      description = "Automated Luogu daily check-in";
      mainProgram = "luogu_checkin";
    };
  };
in
{
  options.services.luogo_checkin = {
    enable = lib.mkEnableOption "luogo_checkin";

    package = lib.mkOption {
      type = lib.types.package;
      default = luogo_checkin;
      description = "The luogo_checkin package to run.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/luogo_checkin.env";
      description = "Path to a dotenv file containing LUOGU_COOKIES and PUSH_KEY.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "luogo_checkin";
      description = "User account under which the check-in service runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "luogo_checkin";
      description = "Group under which the check-in service runs.";
    };
    calendar = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 08:00:00 Asia/Shanghai";
      description = "systemd OnCalendar expression for the check-in timer.";
    };

  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = "/var/lib/luogo_checkin";
      createHome = true;
      description = "Luogu check-in service user";
    };

    users.groups.${cfg.group} = { };

    systemd.services.luogo_checkin = {
      description = "Luogu daily check-in";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = cfg.environmentFile;
        User = cfg.user;
        Group = cfg.group;
      };
    };

    systemd.timers.luogo_checkin = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendar;
        Persistent = true;
        Unit = "luogo_checkin.service";
      };
    };
  };
}
