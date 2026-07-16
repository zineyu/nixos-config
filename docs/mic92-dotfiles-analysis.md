# Research: Secret management in Mic92/dotfiles

## Summary

Mic92/dotfiles uses **sops-nix** through the **clan-core** framework.  Secrets are stored as SOPS-encrypted files under `sops/secrets/<name>/secret`, encrypted for standalone age public keys kept in `sops/machines/<host>/key.json` and `sops/users/<user>/key.json`.  NixOS and nix-darwin modules consume secrets via `config.sops.secrets.<name>.path`.  Deployment is driven by Clan (`machines/inventory.nix` with `deploy.targetHost`/`buildHost`), not deploy-rs.  The repository avoids plaintext secrets by encrypting all private data and uses DNS aliases for host addressing; dynamic secrets are generated on-host with `clan.core.vars.generators`.

## Findings

1. **SOPS/age configuration is split.**  The top-level `.sops.yaml` only defines manual creation rules for `terraform/secrets.enc.json` and `darwin/evo/test-secrets.yml`.  The bulk of the secrets are SOPS JSON files that carry their own age recipients and are auto-discovered by the clan sops module. [Source: `.sops.yaml`, `sops/secrets/bernie-password/secret`, `darwinModules/clan/sops.nix`]

2. **Key management uses separate age keys per machine/user.**  Each machine has an age public key in `sops/machines/<host>/key.json` (e.g. `bernie` → `age1a2qrde2m96u8v6flstyf6mpl4e0996flj32j6rjw3y53l9tln4vsal2pef`).  Each user has an age public key in `sops/users/<user>/key.json`.  The per-machine age private key is itself stored as a sops secret named `<host>-age.key/secret` and installed at `/var/lib/sops-nix/key.txt` (NixOS) or `/Library/Application Support/sops-nix/age-key.txt` (Darwin). [Source: `sops/machines/bernie/key.json`, `sops/users/joerg/key.json`, `sops/secrets/bernie-age.key/secret`, `darwinModules/clan/sops.nix`, `machines/evo/configuration.nix`]

3. **No SSH-to-age conversion is used.**  The repository does not use `sops.age.sshKeyPaths` or derive age keys from SSH host keys.  Age keys are managed independently by Clan.  Host SSH keys are public facts under `machines/<host>/facts/ssh.id_ed25519.pub`. [Source: `machines/bernie/facts/ssh.id_ed25519.pub`, grep output]

4. **Secret directory naming is flat and descriptive.**  The canonical path is `sops/secrets/<name>/secret`.  Names are either host-specific (`<host>-password`, `<host>-wireguard`, `<host>-age.key`) or shared (`openldap-rootpw`, `harmonia-key`).  The `secret` file is SOPS JSON with the actual value encrypted under a top-level `data` field (binary format). [Source: file listing, `sops/secrets/bernie-password/secret`, `sops/secrets/eve-wireguard/secret`]

5. **Secrets are referenced in modules with `config.sops.secrets.<name>.path`.**  Examples include:
   - OpenLDAP root password: `sops.secrets.openldap-rootpw.owner = "openldap";` and `olcRootPW.path = config.sops.secrets.openldap-rootpw.path;` [Source: `nixosModules/openldap/default.nix`]
   - User password: `sops.secrets.shannan-password.neededForUsers = true;` and `hashedPasswordFile = config.sops.secrets.shannan-password.path;` [Source: `nixosModules/shannan.nix`]
   - Remote-builder SSH key: `sshKey = config.sops.secrets.ssh-remote-builder.path;` [Source: `nixosModules/remote-builder.nix`]
   - Dynamic IP-update key: `nsupdate -k ${config.sops.secrets."${config.clan.core.settings.machine.name}-ip-update-key".path}` [Source: `nixosModules/ip-update.nix`]

6. **No Home Manager sops usage was found.**  All sops references are in NixOS/nix-darwin modules.  Home Manager is used for dotfiles but not for secret management in this repository. [Source: grep output]

7. **Dynamic secrets are generated on the host, not stored in the repo.**  The `clan.core.vars.generators` pattern is used for secrets such as `retiolum` (tinc key), `vaultwarden` (admin token, LDAP/SMTP passwords), and `user-password-root`. [Source: `nixosModules/retiolum.nix`, `machines/eve/modules/vaultwarden.nix`, `nixosModules/workstation.nix`]

8. **No custom justfile or sops scripts exist.**  Secret management is delegated to the `clan` CLI from the devShell (`inputs'.clan-core.default`).  `tasks.py` contains helpers for remote ZFS decryption and reboots, but not for sops onboarding. [Source: `devshell/flake-module.nix`, `tasks.py`]

9. **Plaintext secrets and sensitive host addresses are avoided.**  Private values are SOPS-encrypted.  Public host metadata (SSH pub keys, root password hashes, disk IDs) lives in `machines/<host>/facts/`.  Host addresses in Nix configs are DNS aliases (`eve.i`, `eva.i`, `bernie.x`) rather than bare IPs.  Some recovery scripts in `tasks.py` contain hardcoded IPs (e.g. `135.181.61.171`), but these are not in the regular NixOS configuration. [Source: `machines/inventory.nix`, `machines/eve/modules/network.nix`, `tasks.py`]

10. **Deployment uses Clan, not deploy-rs.**  `machines/inventory.nix` defines `deploy.targetHost` and `buildHost` for each machine.  The `clan` CLI wraps `nixos-rebuild --target-host` and handles secret/key delivery during onboarding.  Sops-nix decrypts secrets at system activation on the target using the host’s age key.  Initrd secrets are not managed by sops and are manually copied during installation (see the `FIXME` comment in `machines/eve/modules/network.nix`). [Source: `machines/inventory.nix`, `machines/eve/modules/network.nix`, grep output]

## Sources

- **Kept**: `.sops.yaml` — manual SOPS creation rules for non-clan files.
- **Kept**: `sops/secrets/bernie-password/secret` — representative encrypted secret (SOPS JSON with `data` field).
- **Kept**: `sops/machines/bernie/key.json` and `sops/users/joerg/key.json` — age public key format.
- **Kept**: `darwinModules/clan/sops.nix` — auto-discovery of sops secrets for darwin and age key path setup.
- **Kept**: `nixosModules/openldap/default.nix`, `nixosModules/shannan.nix`, `nixosModules/remote-builder.nix`, `nixosModules/ip-update.nix` — sops secret usage patterns.
- **Kept**: `machines/inventory.nix` — Clan deployment inventory with `targetHost`/`buildHost`.
- **Kept**: `machines/evo/configuration.nix` — explicit darwin age key file path.
- **Kept**: `nixosModules/retiolum.nix`, `machines/eve/modules/vaultwarden.nix`, `nixosModules/workstation.nix` — dynamic on-host secret generation pattern.
- **Dropped**: none — the analysis is based on the local clone.

## Gaps

- The exact `clan` CLI commands used to add, rotate, or onboard hosts are not documented in this repository; they are part of the upstream `clan-core` tooling.
- The exact mechanism that bootstraps the per-machine age private key on a fresh host is not visible in the repo and is likely handled by `clan` during installation.
- No Home Manager sops usage was found, so the repo does not provide a pattern for user-level secrets in Home Manager.

## Actionable takeaways for a personal sops-nix + deploy-rs flake

1. **Adopt a flat per-secret directory structure.**  Use `sops/secrets/<name>/secret` and store secrets in SOPS binary/JSON format.  Prefix host-specific secrets with the hostname and keep shared secrets unprefixed.
2. **Collect age public keys in one place.**  Keep machine/user age public keys under `sops/machines/<host>/age.pub` or `sops/users/<user>/age.pub` and reference them in `.sops.yaml` creation rules so `sops` encrypts to the right recipients automatically.
3. **Use `sops.age.sshKeyPaths` for deploy-rs key distribution.**  On each target, set `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];` so sops-nix derives the age key from the existing persistent SSH host key.  This avoids the chicken-and-egg problem of deploying an age private key separately.
4. **Reference secrets in modules with `config.sops.secrets.<name>.path`.**  Set options such as `owner`, `group`, `mode`, and `neededForUsers = true` for user passwords.
5. **Generate dynamic secrets on the host.**  For random tokens, WireGuard keys, or database passwords, use an activation script or systemd service that creates the file in `/var/lib/<service>` if it does not exist, rather than storing it in the repository.
6. **Avoid plaintext values and IPs in Nix expressions.**  Use DNS names or NixOS options, and encrypt all private values with SOPS.  Put public metadata (SSH pub keys, password hashes) in a `facts/` directory if you need it in the repo.
7. **Exclude encrypted blobs from formatters.**  Add `sops/secrets/`, `*.enc.json`, and other encrypted files to your formatter and `.gitignore` ignore lists so the formatter does not fail on non-Nix files.
8. **Handle initrd/boot secrets outside sops-nix.**  If a secret is needed before sops-nix can run (e.g. an initrd SSH key), use `boot.initrd.secrets` with a manually provisioned file or an out-of-store path, not a sops-nix secret.
9. **Ensure activation order with deploy-rs.**  deploy-rs runs the NixOS activation script, which includes sops-nix; services that depend on secrets should be `after` the sops-nix activation unit (sops-nix typically runs as a `systemd` activation unit, so normal `after = [ "sops-nix.service" ]` suffices).
10. **Do not rely on Clan-specific auto-discovery for deploy-rs.**  In a plain sops-nix setup you must declare `sops.secrets.<name>.sopsFile = ./sops/secrets/<name>/secret;` explicitly, or write a small Nix function that scans the directory and sets `sopsFile` for each entry.

```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "Analyzed the requested secret-management aspects of Mic92/dotfiles (sops-nix configuration, directory structure, module references, scripts/docs, plaintext avoidance, deployment integration) and produced a focused research brief without expanding scope."
    }
  ],
  "changedFiles": [
    "/home/zine/.config/home-manager/.pi-subagents/artifacts/outputs/6e3c2dff/research.md"
  ],
  "testsAddedOrUpdated": [],
  "commandsRun": [],
  "validationOutput": [
    "Research artifact written to the designated output path.  No NixOS configuration or repository code was modified."
  ],
  "residualRisks": [
    "The repository relies on Clan-core behaviours that are not directly portable to deploy-rs; the takeaways above require manual adaptation.",
    "Exact onboarding/rotation commands are not documented in the repo and may differ from upstream clan-core documentation."
  ],
  "noStagedFiles": true,
  "diffSummary": "Wrote the research brief to the artifact output path; no tracked repository files were changed.",
  "reviewFindings": [
    "no blockers"
  ],
  "manualNotes": "Analysis was performed on a local clone at /tmp/mic92-dotfiles provided by the supervisor."
}
```
