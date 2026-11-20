{
  host,
  lib,
  ...
}:

{
  # 缺席轴：nixpkgs 的 chromium 不在 aarch64-darwin 上提供；macOS 用系统安装的
  # 浏览器应用（ADR-0018）。
  config = lib.mkIf host.gates.desktop {
    programs.chromium.enable = true;
  };
}
