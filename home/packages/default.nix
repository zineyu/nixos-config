# 集中包清单（安装侧）：声明 zine.programs.<name>.enable options（默认
# false，即“定义不启用”），并把对应 programs.<name>.enable / 包安装
# 门控到这些开关上。启用发生在 home/<hostname>.nix 机器文件中。
#
# 本文件只聚合跨平台类别；Linux 桌面的 gui.nix 由需要的机器文件显式
# 导入（平台差异由机器文件表达，不再有 linuxOnly 门控）。
#
# 纯裸包（无配置的叶子工具）不在此处：见同目录 tools.nix / dev-tools.nix /
# gui-extras.nix / desktop.nix 等 opt-in 捆绑，由机器文件显式导入。
# 配置统一放 home/programs/、home/desktop/ 等。
{ ... }:

{
  imports = [
    ./shell.nix
    ./dev.nix
    ./terminal.nix
    ./misc.nix
  ];
}
