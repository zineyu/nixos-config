{
  host,
  lib,
  pkgs,
  ...
}:

{
  # 缺席轴：Qt/KDE 下载器，macOS 上不存在 .desktop 关联（ADR-0018）。
  config = lib.mkIf (host.form.pc && host.profile.personal) {
    home.packages = [ pkgs.qbittorrent ];

    # 配置由 qBittorrent 自己在 ~/.config/qBittorrent/qBittorrent.conf 里维护
    # （运行时频繁改写，因此不做 home.file 软链，否则写只读的 store 会失败）。
    # 这里只接管磁力链接与 .torrent 文件的默认打开方式。
    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/magnet" = lib.mkDefault "org.qbittorrent.qBittorrent.desktop";
        "application/x-bittorrent" = lib.mkDefault "org.qbittorrent.qBittorrent.desktop";
      };
      associations.added = {
        "x-scheme-handler/magnet" = lib.mkDefault "org.qbittorrent.qBittorrent.desktop";
        "application/x-bittorrent" = lib.mkDefault "org.qbittorrent.qBittorrent.desktop";
      };
    };
  };
}
