# Justfile: common commands for this NixOS flake
# Requires: just (provided by devenv)

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

# Run flake checks (formatting, deadnix, statix, eval)
check:
    nix flake check --print-build-logs

# Format all Nix files
fmt:
    nix fmt

# Deploy a remote host via deploy-rs
deploy host:
    nix run .#deploy -- .#{{host}}

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
