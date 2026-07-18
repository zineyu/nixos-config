{ pkgs, inputs, ... }:

{
  languages.nix.enable = true;

  git-hooks.hooks = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;
  };

  packages = with pkgs; [
    git
    nixfmt
    deadnix
    statix
    sops
    ssh-to-age
    just
    inputs.deploy-rs.packages.${stdenv.hostPlatform.system}.deploy-rs
  ];
}
