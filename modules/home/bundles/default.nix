# 裸包捆绑：无独立配置模块的叶子软件集合，按用途分组，由 zine.bundles.* 开关启用。
{ ... }:

{
  imports = [
    ./cli.nix
    ./dev.nix
    ./gui.nix
  ];
}
