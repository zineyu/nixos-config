# tianxuan 的 Home Manager 组织文件（全显式）：
# - imports 选择共享定义层与裸包捆绑；
# - zine.programs.* 逐个启用有配置的软件（options 声明见 modules/home/packages/）。
{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/home/packages/tools.nix # CLI 裸包捆绑
    ../modules/home/packages/dev-tools.nix # 开发工具链/Agent 裸包捆绑
    ../modules/home/packages # options 定义层（默认不启用）
    ../modules/home/packages/gui.nix # GUI 程序
    ../modules/home/packages/gui-extras.nix # GUI 裸包捆绑
    ../modules/home/packages/desktop.nix # 桌面环境包捆绑（Linux 桌面）
    ../modules/home/shell
    ../modules/home/desktop
    ../modules/home/programs
    ../modules/home/agent-skills
    ./ssh.nix
  ];

  programs = {
    kitty.font.size = 12.0;
  };

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
    dbx-desktop.enable = true;
    zen-browser.enable = true;
    dolphin.enable = true;

    # misc
    aria2.enable = true;
    gpg.enable = true;
    ssh.enable = true;
    sops.enable = true;
  };

  # Headscale 状态备份：每日从 aliyun-01 拉取快照目录（快照由服务器侧
  # headscale-backup timer 生成，见 modules/nixos/server/headscale.nix）。
  # SSH 走 ./ssh.nix 的 aliyun-01 alias（root@aliyun-01，复用 deploy 的密钥）。
  systemd.user.services.headscale-backup-pull = {
    Unit.Description = "Pull headscale state snapshot from aliyun-01";
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "headscale-backup-pull" ''
          set -eu
          dest="$HOME/backups/headscale"
          mkdir -p "$dest"
          ${pkgs.rsync}/bin/rsync -a --delete -e ssh aliyun-01:/var/lib/headscale-backup/ "$dest/"
        ''
      );
    };
  };
  systemd.user.timers.headscale-backup-pull = {
    Unit.Description = "Daily headscale state backup pull";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
