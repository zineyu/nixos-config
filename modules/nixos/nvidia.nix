# NVIDIA Optimus / PRIME offload。
#
# 广播-门控：被 modules/nixos/default.nix 无条件导入，只有 facts 里列出 nvidia 显卡的
# host 生效。
{ host, lib, ... }:
{
  config = lib.mkIf (lib.elem "nvidia" host.facts.gpu.vendors) {
    hardware.nvidia.prime = {
      offload.enable = true;
      inherit (host.facts.gpu.prime) intelBusId nvidiaBusId;
    };
  };
}
