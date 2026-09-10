# 开发工具链裸包（语言/编译器/构建工具、开发辅助、编码 Agent 与自定义包）。
# 无配置的叶子包集合，作为 opt-in 捆绑由 home/<hostname>.nix 显式导入。
# 有配置的开发程序（git、编辑器等）见 dev.nix 的 options。
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
  # pi-better-edit uses Node's built-in `node:sqlite`, which is unavailable in
  # the Bun standalone runtime used by llm-agents.nix by default.
  piWithNode = llmAgents.pi.override { useBun = false; };
in
{
  home.packages = with pkgs; [
    # 语言、编译器与构建工具
    buf
    bun
    ccache
    (lib.setPrio 20 clang)
    cmake
    dart-sass
    gcc
    gnumake
    go
    llvm
    maven
    mold
    ninja
    tree-sitter
    uv
    python3
    python3Packages.pip
    rustup

    # 开发辅助工具
    github-cli
    lazyjj
    lazygit
    opencode
    stylua

    # 自定义/外部包（定义见仓库根 pkgs/）
    (pkgs.callPackage ../../../pkgs/jj-bond.nix { })

    # 编码 Agent
    llmAgents.codex
    llmAgents.omp
    llmAgents.dsh
    piWithNode
  ];
}
