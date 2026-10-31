{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.zine.programs.dsh;
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.zine.programs.dsh.enable = lib.mkEnableOption "dsh 编码 Agent（llm-agents-nix）";

  config = lib.mkIf cfg.enable {
    home.packages = [ llmAgents.dsh ];
  };
}
