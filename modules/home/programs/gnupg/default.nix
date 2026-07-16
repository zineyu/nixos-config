{
  config,
  lib,
  pkgs,
  ...
}:

let
  signingKey = "EE86111F659E24AB";
  authKeygrip = "C714C773B14F2E777BA919679A5A9DD61B2145D0";
  primaryFingerprint = "B6F9CB026D8DE746C15944E8DDA2A8ACF741A8CD";
  systemctl = config.systemd.user.systemctlPath;
  sopsNixExecStart = lib.escapeShellArgs config.systemd.user.services.sops-nix.Service.ExecStart;

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

  home.packages = with pkgs; [
    age
    sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../../../secrets/gnupg.yaml;
    defaultSopsFormat = "yaml";

    secrets.gnupg_private_key = {
      mode = "0400";
    };
  };

  # sops-nix tries to restart sops-nix.service during activation. On the first
  # generation that introduces sops-nix, the old Home Manager generation has not
  # installed that user unit yet, so restarting it fails. Run the generated
  # sops-nix script directly in that bootstrap case.
  home.activation.sops-nix = lib.mkForce (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;
    sshKeys = [ authKeygrip ];
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  systemd.user.services.import-gnupg-private-key = {
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
}
