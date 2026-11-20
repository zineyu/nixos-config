# Docker 守护进程。
#
# 广播-门控：被 modules/nixos/optional/default.nix 无条件导入，只有带 "docker"
# tag 的 host 生效。这里没有 option：能力不可能与决定它的 metadata 漂移。
{ host, lib, ... }:
{
  config = lib.mkIf (host.hasTag "docker") {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };

    # docker 组由 virtualisation.docker 创建；只有启用 Docker 的 host 才加入，
    # 否则 common/users.nix 会把用户加进不存在的组。
    users.users.zine.extraGroups = [ "docker" ];
  };
}
