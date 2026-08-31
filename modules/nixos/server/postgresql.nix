{ pkgs, ... }:
{
  # 独立管理的 PostgreSQL 实例，供本机服务复用（当前为 vaultwarden）。
  # 默认仅通过 /run/postgresql 的 unix socket 提供本地访问，不监听 TCP。
  # 大版本升级需要手动迁移数据目录（pg_upgrade 或 dump/restore），
  # 因此显式 pin 版本而不是跟随 nixpkgs 默认。
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    # vaultwarden 的数据库与用户，由本实例承载
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
      }
    ];
  };
}
