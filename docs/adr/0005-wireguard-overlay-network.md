# Use a hub-and-spoke WireGuard overlay network

## Status

Accepted

## Date

2026-07-27

## Context

The NixOS hosts need a stable private network that works across a desktop behind NAT, a public server, and future hosts. The repository already has an explicit host registry, shared NixOS modules, and SOPS-backed machine secrets. The network must not depend on a hosted identity/control plane, must not route general Internet traffic, and must preserve the existing public SSH and web-service exposure.

## Decision

Use native WireGuard with `aliyun-01` as a public hub and every other host as a spoke.

- Interface: `wg0`
- Overlay subnet: `10.77.0.0/24`
- Hub: `aliyun-01` at `10.77.0.1`
- Initial spoke: `tianxuan` at `10.77.0.2`
- Hub endpoint: `wg.zineyu.cn:51820/UDP`
- Spokes route only `10.77.0.0/24` through the hub and use a 25-second keepalive.
- The hub enables IPv4 forwarding so spokes can communicate with each other. Because Docker owns the host forwarding path, the hub also installs an idempotent `DOCKER-USER` rule restricted to `wg0` and `10.77.0.0/24`. No masquerading or Internet exit routing is configured.
- Each host's private key is stored in its SOPS-encrypted host secret. External client private keys are stored separately in the administrator-only `secrets/wireguard-clients.yaml`. Public keys, roles, and fixed overlay addresses are non-secret metadata in `vars/default.nix`.
- Every registered host must supply complete WireGuard metadata. Shared assertions reject missing metadata, invalid roles or addresses, malformed public keys, duplicate addresses, and a missing or duplicate hub.
- `/etc/hosts` entries are generated from the shared host and external-peer metadata so overlay members can use hostnames without running an internal DNS service.
- `wg0` is a trusted interface. Existing public SSH, HTTP, and HTTPS rules remain unchanged.

## Alternatives Considered

### Tailscale

- Pros: mature NAT traversal, simple onboarding, centrally managed identity and policy.
- Cons: depends on an external control plane unless another service is operated.
- Rejected because the requested solution is native WireGuard without a hosted control plane.

### Headscale

- Pros: self-hosted Tailscale-compatible control plane with convenient client behavior.
- Cons: adds a stateful service, TLS/domain maintenance, and another availability dependency.
- Rejected because two current hosts do not justify the additional control-plane operations.

### Full-mesh WireGuard

- Pros: direct peer-to-peer paths and no forwarding hub for reachable endpoints.
- Cons: NAT-hosted peers are harder to reach, every new host changes every existing peer set, and endpoint management grows quadratically.
- Rejected in favor of a single stable public endpoint and linear onboarding.

### Internal DNS

- Pros: flexible names and future service discovery.
- Cons: introduces another service and failure mode for a small fixed-address network.
- Rejected for now; generated `/etc/hosts` entries satisfy current requirements.

## Consequences

- `aliyun-01` is a routing dependency for spoke-to-spoke traffic.
- `wg.zineyu.cn` must resolve publicly to the server, and the cloud firewall/security group must permit inbound UDP 51820. NixOS evaluation cannot verify either external condition.
- Adding a NixOS host requires allocating an unused address, generating a keypair, adding the public metadata, creating a host SOPS secret and recipient rule, then deploying the hub before or together with the new spoke.
- External clients such as phones are modeled separately from buildable NixOS hosts. They receive a `/32` address and hub peer entry without a NixOS configuration or system secret.
- Rotating a peer key requires coordinated updates. Update public metadata and encrypted private key, deploy the hub-side peer change, then deploy the peer while retaining an alternative administration path.
- WireGuard members are trusted LAN members and can reach services listening on `wg0` or all interfaces.
- The design intentionally does not provide Internet egress, IPv6 overlay networking, dynamic DNS, or public-entry-point reduction.
