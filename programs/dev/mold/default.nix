{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.mold;

  # mold 只能链接 ELF 目标，在 macOS 上没有任何链接场景。
  # 并且 mold 3.0.0 的 build.rs 在 macOS 上提前返回，不产出 mold-wrapper.so，
  # 而 nixpkgs 的 mold-unwrapped 3.0.0 installPhase 仍然执行
  # `mv $out/lib/mold-wrapper.so $out/lib/mold`，导致 Darwin 上构建失败。
  # 该缺陷属于上游，见 https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/mo/mold-unwrapped/package.nix
  # 因此在 Darwin 上不安装该包。
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.zine.programs.mold.enable = lib.mkEnableOption "mold 链接器";

  config = lib.mkIf (cfg.enable && isLinux) {
    home.packages = [ pkgs.mold ];
  };
}
