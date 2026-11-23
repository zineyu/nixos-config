{
  config,
  host,
  lib,
  pkgs,
  ...
}:

let
  signingKey = "23D4E0D603C3F90E";
  authKeygrip = "84C651B9903AAD75F84998E29EF4E65DD4264F6F";
  primaryFingerprint = "B6F9CB026D8DE746C15944E8DDA2A8ACF741A8CD";
  systemctl = if pkgs.stdenv.hostPlatform.isLinux then config.systemd.user.systemctlPath else null;
  sopsNixExecStart =
    if pkgs.stdenv.hostPlatform.isLinux then
      lib.escapeShellArgs config.systemd.user.services.sops-nix.Service.ExecStart
    else
      lib.escapeShellArg config.launchd.agents.sops-nix.config.Program;

  importGnuPGPrivateKey = pkgs.writeShellScript "import-gnupg-private-key" ''
      set -eu

      secret=${lib.escapeShellArg config.sops.secrets.gnupg_private_key.path}
      if [ ! -r "$secret" ]; then
        echo "Skipping GnuPG private key import: decrypted sops secret is not readable at $secret" >&2
        exit 0
      fi

      export GNUPGHOME=${lib.escapeShellArg config.programs.gpg.homedir}
      mkdir -m 700 -p "$GNUPGHOME"

      ${pkgs.gnupg}/bin/gpg --batch --yes --import "$secret"

      ownertrustFile=$(mktemp)
      trap 'rm -f "$ownertrustFile"' EXIT
      cat > "$ownertrustFile" <<'EOF'
    ${primaryFingerprint}:6:
    EOF
      ${pkgs.gnupg}/bin/gpg --batch --yes --import-ownertrust "$ownertrustFile"
  '';
in
{
  config = {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = ../../../secrets/gnupg.yaml;
      defaultSopsFormat = "yaml";

      secrets.gnupg_private_key = {
        mode = "0400";
      };
    };

    # sops-nix tries to reload its service during activation before Home Manager
    # has installed the service definition on a first generation. Run the generated
    # script directly when the service is unavailable. On Darwin, setupLaunchAgents
    # always runs later in the activation DAG, so the plist cannot be bootstrapped
    # here yet.
    home.activation.sops-nix = lib.mkForce (
      lib.hm.dag.entryAfter [ "writeBoundary" ] (
        if pkgs.stdenv.hostPlatform.isLinux then
          ''
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
            systemdStatus=$(${systemctl} --user is-system-running 2>&1 || true)

            if [[ $systemdStatus == 'running' || $systemdStatus == 'degraded' ]] \
              && ${systemctl} --user cat sops-nix.service >/dev/null 2>&1; then
              ${systemctl} restart --user sops-nix
            else
              run ${sopsNixExecStart}
            fi

            unset systemdStatus
          ''
        else
          ''
            export PATH="''${PATH:+$PATH:}/usr/bin:/bin:/usr/sbin:/sbin"
            run ${sopsNixExecStart}
          ''
      )
    );

    programs.gpg = {
      enable = true;
      settings = {
        default-key = signingKey;
        keyid-format = "0xlong";
        no-emit-version = true;
        no-comments = true;
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        cert-digest-algo = "SHA512";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      };
      dirmngrSettings = {
        keyserver = "hkps://keys.openpgp.org";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      enableFishIntegration = true;
      defaultCacheTtl = 1800;
      defaultCacheTtlSsh = 1800;
      # 口令缓存的最长寿命：agent 常驻到注销/重启，这里的值决定“每隔多久要重新
      # 输一次口令”。30 天足够让日常 push/commit 全程无提示，又不会让解锁后的
      # 私钥长期驻留在内存里。需要更久就调大，想每次都要口令就调回 7200。
      maxCacheTtl = 2592000;
      maxCacheTtlSsh = 2592000;
      sshKeys = [ authKeygrip ];
      # 仓库里没有 gnome-keyring/Gcr，gnome3 版只会退化成 curses 并打一行
      # “No Gcr System Prompter available” 告警；直接选 curses，配合下面登记的
      # startup tty 就能在终端里输入口令。
      pinentry.package =
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
    };

    # gpg-agent 的 ssh 通道拿不到调用方的终端，签名前把 curses pinentry 当成
    # 无终端可用，于是以 ENOTTY 拒绝签名（ssh 侧表现为 "agent refused operation"，
    # jj git push 就停在 Permission denied (publickey)）。下面在可能用到 agent 的
    # 命令执行前，把当前终端登记成 agent 的 startup tty，口令提示才会落在该终端；
    # 缓存有效期内不再询问。
    xdg.configFile = lib.mkIf host.platform.linux {
      "fish/conf.d/gpg-agent-tty.fish".text = ''
        function __gpg_agent_update_tty --on-event fish_preexec
            string match -qr '^\s*(git|jj|ssh|scp|sftp|rsync|gpg)\b' -- $argv[1]; or return

            set -l ttyname (command tty 2>/dev/null)
            test "$ttyname" != "not a tty" -a -n "$ttyname"; or set ttyname $GPG_TTY
            test -n "$ttyname"; or return
            test "$ttyname" != "not a tty"; or return

            set -gx GPG_TTY $ttyname
            command gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1
        end
      '';
    };

    programs.ssh = {
      enableDefaultConfig = false;
    };

    systemd.user.services.import-gnupg-private-key = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "Import GnuPG private key from sops-nix";
        After = [ "sops-nix.service" ];
        Requires = [ "sops-nix.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = toString importGnuPGPrivateKey;
      };

      Install.WantedBy = [ "default.target" ];
    };

    home.activation.importGnuPGPrivateKey =
      lib.hm.dag.entryAfter
        [
          "sops-nix"
          "createGpgHomedir"
        ]
        ''
          run ${importGnuPGPrivateKey}
        '';
  };
}
