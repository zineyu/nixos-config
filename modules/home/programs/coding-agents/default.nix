{ pkgs, inputs, ... }:

{
  home.packages = with inputs.llm-agents-nix.packages.${pkgs.system}; [
    pi
    codex
    cc-switch-cli
  ];
}
