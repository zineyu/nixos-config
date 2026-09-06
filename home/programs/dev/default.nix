# 开发工具链：语言/编译器/构建工具、版本控制、编辑器与 AI 编码代理。
{ extraLibs, ... }:

{
  imports = extraLibs.scanPaths ./.;
}
