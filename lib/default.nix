{ lib }:

{
  # 只导出不依赖 `config` 的辅助函数：`extraLibs` 在 specialArgs 里构造，拿不到
  # HM/NixOS 的 config。
  inherit (import ./scanPaths.nix { inherit lib; }) scanPaths;
}
