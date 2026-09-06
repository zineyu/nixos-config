{
  config,
  hostname,
  lib,
  pkgs,
  vars,
  ...
}:
let
  inherit (lib)
    attrNames
    filterAttrs
    mapAttrs'
    nameValuePair
    optional
    unique
    ;

  registeredHosts = import ../../../hosts;
  hostNames = attrNames registeredHosts;
  nixosHostNames = builtins.filter (name: lib.hasSuffix "-linux" registeredHosts.${name}) hostNames;
  configuredHosts = vars.hosts;
  configuredHostNames = attrNames configuredHosts;
  nixosConfiguredHostNames = builtins.filter (
    name: configuredHosts.${name} ? wireguard
  ) configuredHostNames;
  currentHost = configuredHosts.${hostname} or { };
  currentWireguard = currentHost.wireguard or { };
  currentAddress = currentWireguard.address or "0.0.0.0";
  wireguardHosts = filterAttrs (
    _: host: host ? hostname && host ? wireguard && host.wireguard ? address
  ) configuredHosts;
  hubHosts = filterAttrs (_: host: host.wireguard.role or null == "hub") wireguardHosts;
  spokeHosts = filterAttrs (_: host: host.wireguard.role or null == "spoke") wireguardHosts;
  externalPeers = vars.wireguard.externalPeers or { };
  hubNames = attrNames hubHosts;
  hubName = if hubNames == [ ] then "" else builtins.head hubNames;
  hub = configuredHosts.${hubName} or { };
  isHub = currentWireguard.role or null == "hub";

  addresses =
    (map (name: (configuredHosts.${name}.wireguard or { }).address or "") nixosHostNames)
    ++ map (name: externalPeers.${name}.address or "") (attrNames externalPeers);
  publicKeys =
    (map (name: (configuredHosts.${name}.wireguard or { }).publicKey or "") nixosHostNames)
    ++ map (name: externalPeers.${name}.publicKey or "") (attrNames externalPeers);
  validRole =
    role:
    builtins.elem role [
      "hub"
      "spoke"
    ];
  validAddress =
    address:
    builtins.match "10\\.77\\.0\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])" address != null;
  validPublicKey =
    publicKey:
    builtins.stringLength publicKey == 44 && builtins.match "[A-Za-z0-9+/]{43}=" publicKey != null;

  validHost =
    name:
    let
      host = configuredHosts.${name} or { };
      wireguard = host.wireguard or { };
    in
    (host.hostname or "") == name
    && validAddress (wireguard.address or "")
    && validRole (wireguard.role or "")
    && validPublicKey (wireguard.publicKey or "");

  validExternalPeer =
    name:
    let
      peer = externalPeers.${name};
    in
    (peer.hostname or "") == name
    && validAddress (peer.address or "")
    && validPublicKey (peer.publicKey or "");

  hostAliases =
    mapAttrs' (name: host: nameValuePair host.wireguard.address [ host.hostname ]) wireguardHosts
    // mapAttrs' (name: peer: nameValuePair peer.address [ peer.hostname ]) externalPeers;

  hubPeers =
    map (
      name:
      let
        peer = spokeHosts.${name}.wireguard;
      in
      {
        publicKey = peer.publicKey or "";
        allowedIPs = [ "${peer.address or "0.0.0.0"}/32" ];
      }
    ) (attrNames spokeHosts)
    ++ map (
      name:
      let
        peer = externalPeers.${name};
      in
      {
        publicKey = peer.publicKey or "";
        allowedIPs = [ "${peer.address or "0.0.0.0"}/32" ];
      }
    ) (attrNames externalPeers);

  spokePeers = optional (!isHub && hub ? wireguard) {
    publicKey = hub.wireguard.publicKey or "";
    allowedIPs = [ vars.wireguard.subnet ];
    endpoint = vars.wireguard.endpoint;
    persistentKeepalive = 25;
  };
in
{
  assertions = [
    {
      assertion = lib.all validHost nixosHostNames;
      message = "Every registered NixOS host needs a matching vars.hosts entry and hostname, a 10.77.0.1-254 address, a canonical WireGuard public key, and role hub or spoke.";
    }
    {
      assertion = lib.all validExternalPeer (attrNames externalPeers);
      message = "Every WireGuard external peer needs a matching hostname, a 10.77.0.1-254 address, and a canonical WireGuard public key.";
    }
    {
      assertion = hubNames == [ vars.wireguard.hub ];
      message = "The WireGuard overlay must have exactly one hub matching vars.wireguard.hub.";
    }
    {
      assertion = builtins.length addresses == builtins.length (unique addresses);
      message = "WireGuard overlay addresses must be unique.";
    }
    {
      assertion = builtins.length publicKeys == builtins.length (unique publicKeys);
      message = "WireGuard public keys must be unique across NixOS hosts and external peers.";
    }
    {
      assertion = nixosHostNames == nixosConfiguredHostNames;
      message = "vars.hosts and hosts/default.nix must describe the same host set for NixOS (linux) hosts.";
    }
  ];

  sops.secrets.wireguard_private_key = {
    sopsFile = ../../../secrets + "/${hostname}.yaml";
    format = "yaml";
    mode = "0400";
    restartUnits = [ "wireguard-wg0.service" ];
  };

  networking = {
    hosts = hostAliases;
    firewall = {
      trustedInterfaces = [ "wg0" ];
      allowedUDPPorts = optional isHub vars.wireguard.listenPort;
    };
    wireguard.interfaces.wg0 = {
      ips = [ "${currentAddress}/24" ];
      # The interface address already installs the connected overlay route.
      # Peer AllowedIPs control crypto routing; peer units must not own
      # duplicate kernel routes that may already have disappeared externally.
      allowedIPsAsRoutes = false;
      privateKeyFile = config.sops.secrets.wireguard_private_key.path;
      listenPort = if isHub then vars.wireguard.listenPort else null;
      peers = if isHub then hubPeers else spokePeers;
      # A failed oneshot start does not run postStop. Remove any interface left
      # behind so every start assigns the address and peers from a clean state.
      preSetup = ''
        ip link delete dev wg0 2>/dev/null || true
      '';
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf isHub 1;

  # Docker owns the host FORWARD path and may set its policy to DROP.
  # Install the overlay rule in DOCKER-USER after every daemon start so
  # spoke-to-spoke traffic is accepted without enabling Internet NAT.
  systemd.services.docker = lib.mkIf isHub {
    postStart = lib.mkAfter ''
      ${pkgs.iptables}/bin/iptables -w -C DOCKER-USER \
        -i wg0 -o wg0 \
        -s ${vars.wireguard.subnet} -d ${vars.wireguard.subnet} \
        -j ACCEPT 2>/dev/null \
        || ${pkgs.iptables}/bin/iptables -w -I DOCKER-USER 1 \
          -i wg0 -o wg0 \
          -s ${vars.wireguard.subnet} -d ${vars.wireguard.subnet} \
          -j ACCEPT
    '';
    preStop = lib.mkBefore ''
      ${pkgs.iptables}/bin/iptables -w -D DOCKER-USER \
        -i wg0 -o wg0 \
        -s ${vars.wireguard.subnet} -d ${vars.wireguard.subnet} \
        -j ACCEPT 2>/dev/null || true
    '';
  };
}
