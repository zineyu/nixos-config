# macbook-air-01 的 Home Manager 组织文件（全显式）。
# macbook-air-01 按需选择 Home Manager 模块与软件。
# 平台兼容性由具体软件包定义。
{ pkgs, ... }:

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

  # 在现有的 Zen profile 中强制安装浏览器扩展。
  programs.zen-browser.policies.ExtensionSettings = {
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
    "adguardadblocker@adguard.com" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  # macbook-air-01 专属的代理内核；配置由用户放在 ~/.config/mihomo/。
  home.packages = [ pkgs.mihomo ];
}
