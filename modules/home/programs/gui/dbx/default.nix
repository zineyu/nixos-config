{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  # 上游 flake（t8y2/dbx）固定的 pnpmDeps hash 对应旧 pnpm 版本生成的
  # offline store；nixpkgs 升级 pnpm 11 后解析结果变化（缺 vite-8.2.1），
  # 导致 pnpm install 报 ERR_PNPM_NO_OFFLINE_TARBALL。在此覆盖为新 hash。
  # 重新生成方法：将 outputHash 置为 lib.fakeHash 后构建 pnpmDeps，
  # 取报错中的 "got: sha256-..." 值。
  dbx-desktop = inputs.dbx.packages.${system}.dbx-desktop.overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
      outputHash = "sha256-wkjQz/nNx4D7p5B/5NcdXnMGvOljM+nGKyKDxvMRCgw=";
    });
  });
in
{
  home.packages = [ dbx-desktop ];
}
