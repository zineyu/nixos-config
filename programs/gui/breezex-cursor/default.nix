{
  host,
  lib,
  pkgs,
  ...
}:

{
  # 缺席轴：XCursor 主题包只有 Linux 图形会话用得到（darwin 上 meta.platforms 会拒绝）。
  config = lib.mkIf host.gates.desktop {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
