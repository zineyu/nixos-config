# NVIDIA Optimus / PRIME offload。
#
# 广播-门控：被 modules/nixos/default.nix 无条件导入，只有 host.hasTag "nvidia" 的
# host 生效。能力由事实推导（"nvidia" ∈ facts.gpu.vendors），因此 inventory 里
# 不再声明 nvidia tag：打了 tag 却没写 bus id、或写了 bus id 却没打 tag，这两种
# 非法状态都不会存在（ADR-0018）。
{ host, lib, ... }:
{
  config = lib.mkIf (host.hasTag "nvidia") {
    hardware.nvidia.prime = {
      offload.enable = true;
      inherit (host.facts.gpu.prime) intelBusId nvidiaBusId;
    };
  };
}
