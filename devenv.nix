{ pkgs, inputs, ... }:

{
  languages.nix.enable = true;

  # On Darwin the nixpkgs apple-sdk setup hook points DEVELOPER_DIR at the
  # Nix SDK, which breaks the /usr/bin/xcodebuild shim. enterShell runs after
  # the setup hooks, so point it back at the real Xcode to make Apple tools
  # work inside the dev shell.
  enterShell = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  '';

  git-hooks.hooks = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;
  };

  packages = with pkgs; [
    cachix
    git
    nixfmt
    deadnix
    statix
    sops
    ssh-to-age
    qrencode
    wireguard-tools
    just
    inputs.deploy-rs.packages.${stdenv.hostPlatform.system}.deploy-rs
  ];
}
