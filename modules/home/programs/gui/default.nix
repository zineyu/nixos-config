# 图形界面应用配置：浏览器、文件管理器与桌面外观。
# 仅 Linux 桌面机器导入本类别（见 home/tianxuan.nix）；
# 对应安装开关见 modules/home/packages/gui.nix 的 options。
{ extraLibs, ... }:

{
  imports = extraLibs.scanPaths ./.;
}
