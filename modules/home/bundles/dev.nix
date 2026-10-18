# 开发工具链裸包：语言/编译器/构建工具、开发辅助、编码 Agent 与自定义包。
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.bundles.dev;
  llmAgents = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.zine.bundles.dev.enable = lib.mkEnableOption "开发工具链捆绑";

  config = lib.mkIf cfg.enable {
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
      stylua

      # 自定义/外部包（定义见仓库根 pkgs/）
      (pkgs.callPackage ../../../pkgs/jj-bond.nix { })
      (pkgs.callPackage ../../../pkgs/codegraph.nix { })

      # 编码 Agent
      llmAgents.codex
      llmAgents.dsh
    ];
  };
}
