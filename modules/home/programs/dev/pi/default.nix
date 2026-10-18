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

  # 工作流插件（pi package）：prompts + skills + subagents 扩展三合一。
  # 以 package 身份加载：链接到稳定位置 ~/.pi/agent/packages/，由 settings.json
  # 中的 "./packages/zine-pi-workflow" 相对路径声明引入（该条目为一次性手工配置，
  # 不随 rebuild 变化；链接目标由 home-manager 在每次 switch 时原子更新）。
  workflowDir = ./workflow;

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

    home.file = linkDir ".pi/agent/extensions" extensionsDir // {
      # 工作流插件：以 pi package 身份安装（prompts、skills、subagents 扩展）
      ".pi/agent/packages/zine-pi-workflow".source = workflowDir;
      # virtual-model 扩展的虚拟模型配置
      ".pi/agent/virtual-models.json".source = ./virtual-models.json;
    };
  };
}
