# macbook-air-01 的 Home Manager 组织文件（全显式）。
# 与 tianxuan 的差异：不导入 Linux 桌面相关捆绑、home/desktop、
# packages/gui.nix 与 programs/gui（平台差异完全由此文件的导入列表表达）。
{ ... }:

{
  imports = [
    ./common.nix
    ./packages/tools.nix # CLI 裸包捆绑
    ./packages/dev-tools.nix # 开发工具链/Agent 裸包捆绑
    ./packages # options 定义层（默认不启用）
    ./shell
    ./programs/dev
    ./programs/terminal
    ./programs/misc
    ./ssh.nix
  ];

  zine.programs = {
    # shell
    fish.enable = true;
    bash.enable = true;
    starship.enable = true;

    # terminal
    kitty.enable = true;
    atuin.enable = true;
    yazi.enable = true;
    zellij.enable = true;
    zoxide.enable = true;

    # dev
    git.enable = true;
    jujutsu.enable = true;
    mise.enable = true;
    devenv.enable = true;
    npm.enable = true;
    vscode.enable = true;
    dbeaver.enable = true;
    nixvim.enable = true;
    zed-editor.enable = true;
    fabric.enable = true;

    # misc
    aria2.enable = true;
    gpg.enable = true;
    ssh.enable = true;
    sops.enable = true;
  };
}
