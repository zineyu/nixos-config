# 开发工具链：语言/编译器/构建工具、编辑器与编码 Agent。配置见 programs/dev/。
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
  programs = {
    git.enable = true;
    jujutsu.enable = true;
    mise.enable = true;
    devenv.enable = true;
    npm.enable = true;
    vscode.enable = true;
    dbeaver.enable = true;
    nixvim.enable = true;
    zed-editor.enable = true;
  };

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
    (pkgs.callPackage ../../../pkgs/dsh.nix { })
    (pkgs.callPackage ../../../pkgs/jj-bond.nix { })

    # 编码 Agent
    fabric-ai
    llmAgents.codex
    llmAgents.cc-switch-cli
    llmAgents.omp
    llmAgents.spec-kit
    piWithNode
    inputs.nomic.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
