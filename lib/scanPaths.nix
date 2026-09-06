{ lib }:
{
  scanPaths =
    path:
    map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
        ) (builtins.readDir path)
      )
    );

  # 将 Home Manager 模块包装为仅 Linux 主机生效：返回一个仅含条件 imports 的
  # 模块，darwin 上该模块完全不参与求值（其选项与配置均不存在）。
  # 平台判定来自 mkSystem 注入的 extraSpecialArgs.hostIsLinux（真正的 specialArgs，
  # 不经过 config），因此在模块收集阶段使用不会引起无限递归。
  linuxOnly =
    module:
    { lib, hostIsLinux, ... }:
    {
      imports = lib.optionals hostIsLinux [ module ];
    };
}
