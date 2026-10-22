# macbook-air-01 的 Home Manager 组织文件：导入共享层，再逐个打开开关。
{ pkgs, ... }:

{
  imports = [
    ../modules/home # 用户环境共享层（programs、bundles、ssh、agent-skills 等）
  ];

  zine = {
    bundles = {
      cli.enable = true;
      dev.enable = true;
    };

    programs = {
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
      pi.enable = true;

      # gui
      rustdesk.enable = true;
      dbx-desktop.enable = true;
      zen-browser.enable = true;

      # misc
      gpg.enable = true;
      karabiner-elements.enable = true;
      ssh.enable = true;
      sops.enable = true;
    };
  };

  # macbook-air-01 专属的代理内核 CLI（LaunchDaemon 与配置见 modules/darwin/mihomo）。
  home.packages = [ pkgs.mihomo ];
}
