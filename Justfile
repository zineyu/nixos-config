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

# Run flake checks (formatting, deadnix, statix, eval)
check:
    nix flake check --print-build-logs

# Format all Nix files
fmt:
    nix fmt

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
    export CACHIX_AUTH_TOKEN
    CACHIX_AUTH_TOKEN=$(sops decrypt --extract '["auth_token"]' secrets/cachix.yaml)
    out=$(nix build ".#nixosConfigurations.$1.config.system.build.toplevel" --print-out-paths)
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

# Generate an untracked WireGuard config and QR code for an external client.
# The private key is decrypted only into a mode-0700 directory ignored by Git.
[script]
wireguard-client client:
    set -euo pipefail
    umask 077

    client="$1"
    export WG_CLIENT="$client"
    client_expr='builtins.getAttr (builtins.getEnv "WG_CLIENT") (import ./vars).wireguard.externalPeers'
    peer_exists=$(nix eval --impure --json --expr "builtins.hasAttr (builtins.getEnv \"WG_CLIENT\") (import ./vars).wireguard.externalPeers")
    if [[ "$peer_exists" != true ]]; then
      echo "Unknown WireGuard client: $client" >&2
      exit 1
    fi

    address=$(nix eval --impure --raw --expr "($client_expr).address")
    hub_name=$(nix eval --impure --raw --expr '(import ./vars).wireguard.hub')
    export WG_HUB="$hub_name"
    hub_public_key=$(nix eval --impure --raw --expr '(builtins.getAttr (builtins.getEnv "WG_HUB") (import ./vars).hosts).wireguard.publicKey')
    endpoint=$(nix eval --impure --raw --expr '(import ./vars).wireguard.endpoint')
    subnet=$(nix eval --impure --raw --expr '(import ./vars).wireguard.subnet')

    output_dir=".local/wireguard/$client"
    mkdir -p "$output_dir"

    private_key=$(sops decrypt --extract "[\"${client}_private_key\"]" secrets/wireguard-clients.yaml)
    config="$output_dir/$client.conf"
    printf '%s\n' \
      '[Interface]' \
      "PrivateKey = $private_key" \
      "Address = $address/32" \
      '' \
      '[Peer]' \
      "PublicKey = $hub_public_key" \
      "Endpoint = $endpoint" \
      "AllowedIPs = $subnet" \
      'PersistentKeepalive = 25' \
      > "$config"
    unset private_key

    chmod 0600 "$config"
    qrencode -t PNG -o "$output_dir/$client.png" < "$config"
    echo "Generated $config and $output_dir/$client.png"
    echo "Delete the directory after importing the tunnel into the phone."
