# macbook-air-01 的 User Environment 覆盖。
#
# 软件由各 Program Module 自行声明所需能力；本文件只放无法用 tag 表达的
# user 级机器差异。
{ pkgs, ... }:
{
  # macbook-air-01 专属的代理内核 CLI（LaunchDaemon 与配置见 modules/mihomo）。
  home.packages = [ pkgs.mihomo ];
}
