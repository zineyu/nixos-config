# 图形界面应用：浏览器、IM/邮件、文件管理器与桌面外观（仅 Linux 桌面生效）。
{ extraLibs, ... }:

{
  imports = map extraLibs.linuxOnly (extraLibs.scanPaths ./.);
}
