{
  host,
  lib,
  pkgs,
  ...
}:

let
  breezex-cursor = pkgs.callPackage ../breezex-cursor/package.nix { };
in
{
  # XCursor 主题只对 Linux 图形会话有意义：macOS 的指针由系统管，Home Manager 的
  # home.pointerCursor 在 darwin 上直接断言失败。因此门控在 desktop（形式）而不是
  # gui（会话）上——这是"同一程序在不同设备上缺席"的典型例子（ADR-0018）。
  config = lib.mkIf (host.hasTag "gui" && host.platform.nixos) {
    home.pointerCursor = {
      enable = true;
      name = "BreezeX-Light";
      package = breezex-cursor;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
