# macbook-air-01 的 Home Manager 组织文件（全显式）。
# macbook-air-01 按需选择 Home Manager 模块与软件。
# 平台兼容性由具体软件包定义。
{ ... }:

{
  imports = [
    ./common.nix
    ../modules/home/packages/tools.nix # CLI 裸包捆绑
    ../modules/home/packages/dev-tools.nix # 开发工具链/Agent 裸包捆绑
    ../modules/home/packages # options 定义层（默认不启用）
    ../modules/home/shell
    ../modules/home/programs/dev
    ../modules/home/programs/terminal
    ../modules/home/programs/misc
    ../modules/home/programs/gui/zen-browser
    ../modules/home/packages/gui.nix # GUI 程序
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

    # gui
    zen-browser.enable = true;
  };
}
