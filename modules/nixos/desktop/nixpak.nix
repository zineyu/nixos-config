# modules/home/programs/qq 与 modules/home/programs/wechat 消费本文件定义的
# pkgs.nixpaks.* overlay，即 home 层依赖 nixos 层 overlay 的耦合。该耦合目前
# 成立的前提是 mkSystem（lib/mkSystem.nix）始终把 Home Manager 作为 NixOS
# 模块集成并启用 useGlobalPkgs；若将来独立使用 Home Manager 需同步迁移本 overlay。
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        mkNixPak = inputs.nixpak.lib.nixpak {
          pkgs = prev;
          inherit (prev) lib;
        };
      in
      {
        nixpaks = {
          qq = prev.callPackage ../../../lib/nixpaks-qq.nix { inherit mkNixPak; };
          wechat = prev.callPackage ../../../lib/nixpaks-wechat.nix { inherit mkNixPak; };
        };
      }
    )
  ];
}
