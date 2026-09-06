# 图形界面应用（仅 Linux 桌面，由 packages/default.nix 通过 linuxOnly 引入）。
# 配置见 programs/gui/。
{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  # 上游 flake（t8y2/dbx）固定的 pnpmDeps hash 对应旧 pnpm 版本生成的
  # offline store；nixpkgs 升级 pnpm 11 后解析结果变化（缺 vite-8.2.1），
  # 导致 pnpm install 报 ERR_PNPM_NO_OFFLINE_TARBALL。在此覆盖为新 hash。
  # 重新生成方法：将 outputHash 置为 lib.fakeHash 后构建 pnpmDeps，
  # 取报错中的 "got: sha256-..." 值。

  # dbx-desktop = inputs.dbx.packages.${system}.dbx-desktop.overrideAttrs (old: {
  #   pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
  #     outputHash = "sha256-wkjQz/nNx4D7p5B/5NcdXnMGvOljM+nGKyKDxvMRCgw=";
  #   });
  # });

  dbx-desktop = inputs.dbx.packages.${system}.dbx-desktop;
in
{
  programs = {
    firefox.enable = true;
    chromium.enable = true;
    thunderbird.enable = true;
    zen-browser.enable = true;
  };

  home.packages = with pkgs; [
    kdePackages.dolphin
    localsend
    nixpaks.qq
    nixpaks.wechat

    dbx-desktop

    # 自定义/外部包（定义见仓库根 pkgs/）
    (pkgs.callPackage ../../../pkgs/orca.nix { })
    (pkgs.callPackage ../../../pkgs/easycliproxyapi.nix { })
    (pkgs.callPackage ../../../pkgs/breezex-cursor.nix { })
  ];
  # programs/gui/cursor 的 home.pointerCursor.package 引用同一 derivation，
  # 用于生成指针主题配置；两处引用同一 store path，不会重复安装。
}
