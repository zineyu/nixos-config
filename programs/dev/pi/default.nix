{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.pi;
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};

  # pi 扩展源目录：单文件扩展直接放 .ts 文件，目录扩展放含 index.ts 的子目录。
  # 新增扩展只需放入该目录，无需修改本文件。
  extensionsDir = ./extensions;

  # 把源目录中的每个文件链接到目标前缀下
  linkDir =
    targetPrefix: dir:
    builtins.listToAttrs (
      map (name: {
        name = "${targetPrefix}/${name}";
        value.source = dir + "/${name}";
      }) (builtins.attrNames (builtins.readDir dir))
    );
in
{
  options.zine.programs.pi.enable = lib.mkEnableOption "pi 编码 Agent";

  config = lib.mkIf cfg.enable {
    home.packages = [ llmAgents.pi ];

    home.file = linkDir ".pi/agent/extensions" extensionsDir;
  };
}
