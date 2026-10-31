# 平台无关的 Home Manager 基础层：兼容版本、agent skills 与用户级服务。
# 由 lib/mkSystem.nix 接入每个用户环境，机器文件无需导入。
{ ... }:

{
  imports = [
    ./common.nix
    ./agent-skills
    ./services
  ];
}
