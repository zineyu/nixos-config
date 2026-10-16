# tianxuan 的 Home Manager 组织文件：导入共享层，再逐个打开开关。
{ ... }:

{
  imports = [
    ../modules/home # 用户环境共享层（programs、bundles、ssh、agent-skills 等）
    ../modules/home/desktop # Linux 桌面层（niri + DankMaterialShell + 字体）
  ];

  zine = {
    bundles = {
      cli.enable = true;
      dev.enable = true;
      gui.enable = true;
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
      firefox.enable = true;
      chromium.enable = true;
      thunderbird.enable = true;
      dbx-desktop.enable = true;
      zen-browser.enable = true;
      dolphin.enable = true;
      cursor.enable = true;

      # misc
      aria2.enable = true;
      gpg.enable = true;
      ssh.enable = true;
      sops.enable = true;
    };

    services.headscale-backup-pull.enable = true;
  };

  programs.kitty.font.size = 12.0;
}
