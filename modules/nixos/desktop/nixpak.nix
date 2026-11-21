# programs/gui/qq 与 programs/gui/wechat 消费 overlays/nixpaks.nix 定义的
# pkgs.nixpaks.* overlay，即 Home Manager 层依赖系统层 overlay 的耦合。该耦合目前
# 成立的前提是 mkSystem（lib/mkSystem.nix）始终把 Home Manager 作为 NixOS
# 模块集成并启用 useGlobalPkgs；若将来独立使用 Home Manager 需同步迁移该 overlay。
{ inputs, ... }:
{
  nixpkgs.overlays = [ (import ../../../overlays/nixpaks.nix { inherit inputs; }) ];
}
