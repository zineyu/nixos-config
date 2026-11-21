# 平台无关的 Home Manager 基础层：兼容版本、agent skills 与用户级服务。
# 由 modules/home-manager/default.nix 广播，lib/mkSystem.nix 接入每个用户环境。
{ ... }:

{
  imports = [
    ./common.nix
    ./agent-skills
  ];
}
