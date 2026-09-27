{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.pi;

  # pi 扩展源目录：单文件扩展直接放 .ts 文件，目录扩展放含 index.ts 的子目录。
  # 新增扩展只需放入该目录，无需修改本文件。
  extensionsDir = ./extensions;

  # pi prompt 模板目录：每个 .md 文件注册为一个 /<文件名> 命令。
  # 新增模板只需放入该目录，无需修改本文件。
  promptsDir = ./prompts;

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
  config = lib.mkIf cfg.enable {
    home.file =
      linkDir ".pi/agent/extensions" extensionsDir
      // linkDir ".pi/agent/prompts" promptsDir
      // {
        # virtual-model 扩展的虚拟模型配置
        ".pi/agent/virtual-models.json".source = ./virtual-models.json;
      };
  };
}
