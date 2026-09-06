# tianxuan 的 Home Manager 组织文件（全显式）：
# - imports 选择共享定义层与裸包捆绑；
# - zine.programs.* 逐个启用有配置的软件（options 声明见 home/packages/）。
{ ... }:

{
  imports = [
    ./common.nix
    ./packages/tools.nix # CLI 裸包捆绑
    ./packages/dev-tools.nix # 开发工具链/Agent 裸包捆绑
    ./packages # options 定义层（默认不启用）
    ./packages/gui.nix # GUI 程序 options（Linux 桌面）
    ./packages/gui-extras.nix # GUI 裸包捆绑（Linux 桌面）
    ./packages/desktop.nix # 桌面环境包捆绑（Linux 桌面）
    ./shell
    ./desktop
    ./programs
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

    # gui
    firefox.enable = true;
    chromium.enable = true;
    thunderbird.enable = true;
    zen-browser.enable = true;
    dolphin.enable = true;

    # misc
    aria2.enable = true;
    gpg.enable = true;
    ssh.enable = true;
    sops.enable = true;
  };
}
