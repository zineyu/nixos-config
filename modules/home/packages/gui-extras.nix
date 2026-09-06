# 图形界面裸包（无独立配置模块的 GUI 软件）。
# 作为 opt-in 捆绑由 home/<hostname>.nix 显式导入；
# 有配置的 GUI 程序见 gui.nix 的 options。
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    localsend
    nixpaks.qq
    nixpaks.wechat
    # 自定义/外部包（定义见仓库根 pkgs/）
    (pkgs.callPackage ../../../pkgs/orca.nix { })
    (pkgs.callPackage ../../../pkgs/easycliproxyapi.nix { })
    (pkgs.callPackage ../../../pkgs/breezex-cursor.nix { })
  ];
  # modules/home/programs/gui/cursor 的 home.pointerCursor.package 引用同一 derivation，
  # 用于生成指针主题配置；两处引用同一 store path，不会重复安装。
}
