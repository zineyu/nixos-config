# Self-host a Headscale control plane and migrate the overlay to a tailnet

## Status

Accepted (supersedes ADR-0005)

## Date

2026-09-19

## Context

ADR-0005 built a hub-and-spoke native WireGuard overlay (`10.77.0.0/24`, hub `aliyun-01`). The primary usage has since crystallized into a remote-development workflow: a desktop (`tianxuan`) runs backend Docker services and a frontend dev server, while a laptop (`macbook-air-01`) and a phone (`xiaomi15`) access the frontend for testing and debugging. Against this usage, two structural pains dominate:

- **Onboarding is manual.** Adding any device requires generating a keypair, editing shared metadata, creating SOPS secrets and recipient rules, and coordinating hub/spoke deployments.
- **There is no DNS or service discovery.** Name resolution is generated `/etc/hosts` entries, which only covers registered NixOS hosts and does not name services.

Secondary observations: spoke-to-spoke traffic (the dominant flow for remote development) always transits the hub with no possibility of direct peer-to-peer paths, and the network is expected to grow modestly (5-10 members). The requirement against a hosted identity/control plane from ADR-0005 is explicitly relaxed: a **self-hosted** control plane is now acceptable, while a hosted third-party control plane remains rejected.

## Decision

Self-host [Headscale](https://headscale.net) on `aliyun-01` as the coordination server and migrate all overlay members to the resulting tailnet, then retire the native WireGuard overlay.

- **Control plane**: Headscale (single Go binary, SQLite state) served at `https://hs.zineyu.cn`, behind the existing nginx + ACME pattern used by vaultwarden/atuin/gotify. State directory must be backed up (SQLite database + Noise private key); a minimal rsync-to-`tianxuan` job with a short restore runbook is part of the initial deployment.
- **Relay and NAT traversal**: use Headscale's embedded DERP relay (requires headscale >= 0.26; the pinned nixpkgs provides 0.29.3) served on the same HTTPS endpoint, plus its embedded STUN server on UDP 3478. Tailscale's public DERP network is not relied upon (unreliable reachability from mainland China). The cloud security group must additionally permit inbound UDP 3478.
- **Clients**:
  - Repo-managed hosts (`tianxuan`, `aliyun-01`, `macbook-air-01`): `services.tailscale` with a reusable preauth key stored in a single shared SOPS file (`secrets/tailscale.yaml`, key `preauth_key`; recipients cover all repo-managed machines). NixOS hosts use the module's `authKeyFile` autoconnect; the nix-darwin host uses an equivalent LaunchDaemon (the nix-darwin module has no `authKeyFile`), plus a `/etc/resolver/ts.zineyu.cn` entry so the custom MagicDNS base domain resolves through quad100. Enrollment is fully declarative after a one-time key provisioning step, key rotation touches exactly one file, and lost node state self-heals.
  - `xiaomi15` (Android): official Tailscale app pointed at `https://hs.zineyu.cn`, registered with `headscale nodes register`. APK acquisition outside Play Store is an onboarding checklist item.
- **Addressing**: default Tailscale CGNAT range `100.64.0.0/10`. The hand-allocated `10.77.0.0/24` plan is retired along with all per-host WireGuard metadata.
- **DNS**: Headscale MagicDNS with base domain `ts.zineyu.cn` (must differ from the server URL host; needs no public DNS records since quad100 answers on each node). Node names equal hostnames (e.g. `tianxuan.ts.zineyu.cn`). Service names (`vault`, `atuin`, `gotify`) keep their existing public domains; extra tailnet DNS records can be added later if wanted. Generated `/etc/hosts` aliases are removed.
- **Firewall posture**: `tailscale0` becomes a trusted interface on NixOS hosts, preserving the current "tailnet members are trusted LAN members" posture so dev servers on arbitrary ports stay reachable. ACL policy starts single-user allow-all; tags/segmentation are deferred until multi-user or untrusted devices appear.
- **Migration**: direct cutover in a single change (deploy Headscale, enroll all nodes, remove the WireGuard overlay) instead of a phased dual-network transition. Public SSH on `aliyun-01` remains as the fallback administration channel during cutover.

## Alternatives Considered

### NetBird (self-hosted)

- Pros: native WireGuard data plane, built-in DNS/ACL, active project, team-oriented features.
- Cons: the self-hosted stack is five-plus components (management, signal, relay, dashboard, identity provider) for a single administrator and 5-10 devices.
- Rejected as operationally disproportionate; Headscale covers the same requirement set with one binary and SQLite.

### Keep native WireGuard, add DNS and onboarding tooling

- Pros: no new service, no client apps, keeps the declared-software-only model.
- Cons: key distribution and peer-set updates stay manual (the stated pain), and hub-and-spoke can never provide direct peer-to-peer paths for the dominant laptop-to-desktop traffic.
- Rejected as addressing symptoms rather than the stated requirements.

### Hosted Tailscale control plane

- Pros: best onboarding UX, mature clients, zero control-plane operations.
- Cons: identity and policy depend on a third-party hosted service.
- Rejected; the accepted relaxation covers self-hosted control planes only.

## Consequences

- **Larger single failure domain on `aliyun-01`.** It now hosts both the control plane and the only DERP relay. If it fails, established peer-to-peer sessions survive, but new devices cannot join and pairs that cannot hole-punch lose connectivity entirely. Accepted at this scale; mitigated by state backup plus a restore runbook.
- **New critical state.** Losing the Headscale SQLite database or Noise key forces re-registration of every node. The backup job is not optional.
- **Dual authorization model.** Repo-managed hosts enroll automatically via the reusable preauth key in the shared SOPS file `secrets/tailscale.yaml`. All other devices use client-generated keys plus explicit server-side approval (`headscale nodes register`), so no standing credential exists for them. The preauth key is created once by hand after the control plane is up (`headscale preauthkeys create --user zine --reusable`) and written into the shared secret; its expiry does not affect registered nodes, but re-registration after state loss requires a fresh key in SOPS. Fully automatic enrollment of *unmanaged* devices was rejected: auto-approving unknown nodes defeats the purpose of authorization.
- **Client dependency.** Enrollment depends on Tailscale client software (nixpkgs `tailscale` on Linux, official app on Android/iOS). Client acquisition channels for mainland-China devices must be verified during enrollment.
- **External prerequisites unchanged in kind**: `hs.zineyu.cn` must resolve publicly (and be compatible with the domain's filing/备案 status), and the cloud security group must permit TCP 443 (already open) plus UDP 3478 (new).
- **Rollback path**: the WireGuard modules remain in git history for restoration if the tailnet proves unworkable; public SSH access to `aliyun-01` is never removed, so remote recovery does not depend on either overlay.
- The design intentionally still does not provide Internet egress (exit nodes), LAN subnet routing, or multi-user access control; all three are straightforward tailnet features if requirements change.
- **Coexistence with fake-IP proxies (tianxuan/macbook-air-01 mihomo TUN).** tailscaled marks its control-plane sockets with fwmark `0x80000`, which bypasses the mihomo TUN interception. If the control-plane domain is answered with a fake IP, tailscaled dials an unroutable address and login hangs until timeout. Hosts running a fake-IP proxy must therefore keep `hs.zineyu.cn` in the proxy's `fake-ip-filter` (real-IP resolution, direct dial) and route `+.ts.zineyu.cn` to `100.100.100.100` via `nameserver-policy` (MagicDNS lookups).
