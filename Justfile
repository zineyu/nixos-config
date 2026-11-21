# Justfile: common commands for this NixOS flake
# Requires: just (provided by devenv)

set positional-arguments

# List available recipes
[private]
default:
    @just --list

# Build a host configuration without activating it
build host:
    nixos-rebuild build --flake .#{{host}}

# Switch a host configuration (requires confirmation in real use)
switch host:
    sudo nixos-rebuild switch --flake .#{{host}}

# Build a Darwin host configuration without activating it
build-darwin host:
    nix build .#darwinConfigurations.{{host}}.system

# Switch a Darwin host configuration (requires confirmation in real use)
switch-darwin host:
    sudo darwin-rebuild switch --flake .#{{host}}
# Run flake checks (formatting, deadnix, statix, eval)
check:
    nix flake check --print-build-logs

# Format all Nix files
fmt:
    nix fmt

# Lint every skill under skills/ (frontmatter, naming, triggers, link targets)
lint-skills:
    python3 scripts/lint-skills.py

# Lint how host differences are expressed (ADR-0018: R1-R5)
lint-structure:
    python3 scripts/lint-structure.py

# List the Home Manager program modules each host enables.
[script]
programs:
    set -uo pipefail
    probe='u: let
      lower = n: builtins.match "[a-z0-9-]+" n != null;
      on = n: let r = builtins.tryEval (u.programs.${n}.enable or false); in r.success && r.value == true;
    in builtins.filter (n: lower n && on n) (builtins.attrNames u.programs)'
    for set in nixosConfigurations darwinConfigurations; do
      for h in $(nix eval --json ".#$set" --apply builtins.attrNames | tr -d '[]" ' | tr ',' ' '); do
        printf '%-18s' "$h"
        if out=$(nix eval --json ".#$set.$h.config.home-manager.users.zine" --apply "$probe" 2>/dev/null); then
          printf ' %s\n' "$(echo "$out" | python3 -c 'import json,sys; print(", ".join(sorted(json.load(sys.stdin))) or "-")')"
        else
          printf ' -（无 User Environment 或求值失败）\n'
        fi
      done
    done

# Print what each host derives: docker / tailscale / mihomo / nvidia / sshd.
[script]
table:
    set -euo pipefail
    probe='hosts: builtins.mapAttrs (_: h: {
      docker = h.config.virtualisation.docker.enable or null;
      tailscale = h.config.services.tailscale.enable or null;
      mihomo = h.config.services.mihomo.enable or null;
      nvidia = h.config.hardware.nvidia.prime.offload.enable or null;
      sshd = h.config.services.openssh.enable or null;
    }) hosts'
    nixos=$(nix eval --json .#nixosConfigurations --apply "$probe")
    darwin=$(nix eval --json .#darwinConfigurations --apply "$probe")
    python3 - "$nixos" "$darwin" <<'PY'
    import json, sys
    keys = ("docker", "tailscale", "mihomo", "nvidia", "sshd")
    print(f"{'host':<18}" + "".join(f"{k:<10}" for k in keys))
    for blob in sys.argv[1:]:
        for host, flags in sorted(json.loads(blob).items()):
            cells = "".join(f"{('-' if flags[k] is None else str(flags[k]).lower()):<10}" for k in keys)
            print(f"{host:<18}{cells}")
    PY

# Update flake inputs; nixpkgs pinned to the nixos-unstable channel rev (see scripts/update-flake.sh)
update:
    ./scripts/update-flake.sh

# Deploy a remote host via deploy-rs
deploy host:
    nix run .#deploy -- .#{{host}}

# Build a host's system closure and push it to the zineyu cachix cache.
# Reads the auth token from sops-encrypted secrets/cachix.yaml; create it once
# with `just cachix-token` (content: `auth_token: <token>`).
[script]
push-cachix host=`hostname`:
    set -euo pipefail
    if [[ ! -f secrets/cachix.yaml ]]; then
      echo "secrets/cachix.yaml not found." >&2
      echo "Create it with 'just cachix-token' and add: auth_token: <your cachix auth token>" >&2
      exit 1
    fi
    out=$(nix build ".#$1" --print-out-paths)
    export CACHIX_AUTH_TOKEN
    CACHIX_AUTH_TOKEN=$(sops decrypt --extract '["auth_token"]' secrets/cachix.yaml)
    cachix push zineyu "$out"

# Edit the encrypted cachix auth token used by push-cachix
cachix-token:
    sops secrets/cachix.yaml

# Edit the encrypted SSH hosts alias file
ssh-hosts:
    sops secrets/ssh-hosts.yaml

# Edit an encrypted host secret (e.g. just sops-edit aliyun-01)
sops-edit host:
    sops secrets/{{host}}.yaml

# Re-encrypt all secrets with current recipients from .sops.yaml
sops-updatekeys:
    sops updatekeys secrets/*.yaml

# Fetch the age public key from a remote host via SSH-to-age
age-key host:
    ssh root@{{host}} "nix-shell -p ssh-to-age --run 'ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub'"
