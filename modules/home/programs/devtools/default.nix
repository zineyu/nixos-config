# 编程语言、编译器、构建与开发辅助工具；日常通用 CLI 工具见 modules/home/tools.nix。
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    buf
    bun
    ccache
    (lib.setPrio 20 clang)
    cmake
    dart-sass
    gcc
    github-cli
    gnumake
    go
    lazyjj
    llvm
    maven
    mold
    ninja
    opencode
    stylua
    tree-sitter
    uv
  ];
}
