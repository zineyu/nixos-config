# 用户级 systemd 服务与定时任务。
{ extraLibs, ... }:

{
  imports = extraLibs.scanPaths ./.;
}
