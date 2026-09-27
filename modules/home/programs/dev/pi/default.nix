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
in
{
  config = lib.mkIf cfg.enable {
    home.file =
      builtins.listToAttrs (
        map (name: {
          name = ".pi/agent/extensions/${name}";
          value.source = extensionsDir + "/${name}";
        }) (builtins.attrNames (builtins.readDir extensionsDir))
      )
      // {
        # virtual-model 扩展的虚拟模型配置
        ".pi/agent/virtual-models.json".source = ./virtual-models.json;
      };
  };
}
