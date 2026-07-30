# modules/home/programs/gui/qq 与 modules/home/programs/gui/wechat 消费本文件定义的
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
        # 临时修复：nixpkgs 中的 qq 3.2.29 下载链接已从腾讯云 CDN 下架
        # （CI runner 访问返回 404），覆盖为官方当前发布的 3.2.32。
        # TODO: nixpkgs 更新 linuxqq 到 3.2.32 后移除此覆盖。
        # 官方下载信息来源：https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxConfig.js
        qq = prev.qq.overrideAttrs (_old: {
          version = "3.2.32-2026-07-30";
          src = prev.fetchurl {
            url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/c97651b2/QQ_3.2.32_260730_amd64_01.deb";
            hash = "sha256-ga4rhULvUxH8cuz1PJpSOSPINFacew2lLgv0Nguctfk=";
          };
        });
      in
      {
        nixpaks = {
          # prev.callPackage 的作用域不含本 overlay 的定义，需显式传入修复后的 qq
          qq = prev.callPackage ../../../lib/nixpaks-qq.nix { inherit mkNixPak qq; };
          wechat = prev.callPackage ../../../lib/nixpaks-wechat.nix { inherit mkNixPak; };
        };
      }
    )
  ];
}
