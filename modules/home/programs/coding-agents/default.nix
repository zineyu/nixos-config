{ pkgs, inputs, ... }:

{
  home.packages = with inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}; [
    pi
    codex
    cc-switch-cli
  ];
}
