{
  config,
  lib,
  pkgs,
  vars,
  ...
}:

let
  cfg = config.zine.programs.rustdesk;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  # 自建服务端（hbbs/hbbr，aliyun-01）地址；服务端部署与密钥预置见
  # modules/nixos/server/rustdesk.nix，公钥在 vars.rustdesk.publicKey。
  server = "aliyun-01.ts.zineyu.cn";

  # 服务器三项 + 加密公钥，写入客户端的 [options]（RustDesk2.toml，
  # 见 hbb_common Config2；键名见 rustdesk libs/base/src/config/keys.rs）。
  rustdesk2Toml = pkgs.writeText "RustDesk2.toml" ''
    [options]
    custom-rendezvous-server = "${server}"
    relay-server = "${server}"
    key = "${vars.rustdesk.publicKey}"
  '';

  # macOS 的 ProjectDirs 路径片段为 qualifier.org.app = com.carriez.RustDesk
  # （ORG 见 hbb_common，config.rs 默认 "com.carriez"）。
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/com.carriez.RustDesk"
    else
      ".config/rustdesk";
in
{
  options.zine.programs.rustdesk.enable = lib.mkEnableOption "RustDesk 客户端";

  config = lib.mkIf cfg.enable {
    # 客户端本体：Linux 用 nixpkgs 的 rustdesk-flutter；macOS 由
    # hosts/<hostname>/default.nix 的 homebrew cask 提供（签名 + LaunchDaemon，
    # nixpkgs 的 rustdesk-flutter 仅支持 linux）。
    home.packages = lib.optionals isLinux [ pkgs.rustdesk-flutter ];

    # Linux 被控常驻：rustdesk --server 在用户图形会话内运行，Wayland 屏幕采集
    # 与输入注入都走 RemoteDesktop/ScreenCast portal（1.4.x，src/server/rdp_input.rs、
    # libs/scrap/src/wayland/），免 root；portal 授权一次后由 restore token 记忆。
    # macOS 由 cask 安装包自带的 LaunchDaemon 负责，无需 user service。
    systemd.user.services.rustdesk = lib.mkIf isLinux {
      Unit = {
        Description = "RustDesk 被控常驻服务";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.rustdesk-flutter} --server";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # 服务器配置只做一次性声明式落地：RustDesk 运行时会整体重写自身配置文件，
    # 之后由客户端自管（后续 switch 不会覆盖已有文件）。文件不存在时写入，
    # 避免覆盖客户端自管后的状态。注意配置仅 0600（store_path_perms）。
    home.activation.rustdeskConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cfg="${config.home.homeDirectory}/${configDir}/RustDesk2.toml"
      if [[ ! -e "$cfg" ]]; then
        $DRY_RUN_CMD install -Dm600 ${rustdesk2Toml} "$cfg"
      fi
    '';
  };
}
