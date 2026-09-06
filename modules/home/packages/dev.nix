# 有配置的开发程序（编辑器、版本控制、运行时管理等）：逐个 option 门控。
# 配置见 modules/home/programs/dev/；裸工具链与编码 Agent 见 dev-tools.nix（opt-in）。
#
# 注意：nixvim 的 Home Manager 模块由 modules/home/programs/dev/nixvim 导入，
# 机器文件需同时导入 modules/home/programs 才能使用 zine.programs.nixvim。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs;
in
{
  options.zine.programs = {
    git.enable = lib.mkEnableOption "git";
    jujutsu.enable = lib.mkEnableOption "jujutsu";
    mise.enable = lib.mkEnableOption "mise 运行时管理器";
    devenv.enable = lib.mkEnableOption "devenv";
    npm.enable = lib.mkEnableOption "npm 配置";
    vscode.enable = lib.mkEnableOption "VS Code";
    dbeaver.enable = lib.mkEnableOption "DBeaver";
    nixvim.enable = lib.mkEnableOption "Neovim (nixvim)";
    zed-editor.enable = lib.mkEnableOption "Zed 编辑器";
    fabric.enable = lib.mkEnableOption "fabric AI";
  };

  config = {
    programs = {
      git.enable = cfg.git.enable;
      jujutsu.enable = cfg.jujutsu.enable;
      mise.enable = cfg.mise.enable;
      devenv.enable = cfg.devenv.enable;
      npm.enable = cfg.npm.enable;
      vscode.enable = cfg.vscode.enable;
      dbeaver.enable = cfg.dbeaver.enable;
      nixvim.enable = cfg.nixvim.enable;
      zed-editor.enable = cfg.zed-editor.enable;
    };

    home.packages = with pkgs; lib.optionals cfg.fabric.enable [ fabric-ai ];
  };
}
