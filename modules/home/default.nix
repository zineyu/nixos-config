# 用户环境共享层：基础状态、程序配置、agent skills 与裸包捆绑。
# 机器组织文件（home/<hostname>.nix）导入本层后用 zine.programs.* /
# zine.bundles.* / zine.services.* 开关选择实际启用的内容。
{ ... }:

{
  imports = [
    ./common.nix
    ../../programs
    ./agent-skills
    ./bundles
    ./services
  ];
}
