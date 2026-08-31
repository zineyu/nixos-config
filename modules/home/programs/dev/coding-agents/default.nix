{ pkgs, inputs, ... }:

let
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
  # pi-better-edit uses Node's built-in `node:sqlite`, which is unavailable in
  # the Bun standalone runtime used by llm-agents.nix by default.
  piWithNode = llmAgents.pi.override { useBun = false; };
in
{
  home.packages =
    with llmAgents;
    [
      piWithNode
      codex
      cc-switch-cli
      omp
      spec-kit
    ]
    ++ [ inputs.nomic.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
