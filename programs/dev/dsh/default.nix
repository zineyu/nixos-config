{
  pkgs,
  inputs,
  ...
}:

let
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = {
    home.packages = [ llmAgents.dsh ];
  };
}
