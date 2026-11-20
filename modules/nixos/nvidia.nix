# NVIDIA Optimus / PRIME offload。
#
# 广播-门控：被 modules/nixos/default.nix 无条件导入，只有带 "nvidia" tag 的
# host 生效；PCI bus id 是机器事实，仍来自 vars.hosts.<hostname>.hardware。
{ host, lib, vars, ... }:
let
  nvidia = host.gates.nvidia;
  facts = vars.hosts.${host.name}.hardware;
in
{
  config = lib.mkIf nvidia {
    hardware.nvidia.prime = {
      offload.enable = true;
      inherit (facts) intelBusId nvidiaBusId;
    };
  };
}
