{ ... }:

{
  programs.zellij = {
    enable = true;
    # Converted from the previous hand-maintained config.kdl; verified to
    # produce a semantically identical KDL tree via lib.hm.generators.toKDL.
    settings = import ./settings.nix;
  };
}
