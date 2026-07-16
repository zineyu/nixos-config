# Host registry.
#
# Maps each hostname to the system architecture it builds for.
# To add a new host:
#   1. Create hosts/<hostname>/default.nix as a NixOS module.
#   2. Add hosts/<hostname>/configuration.nix and hardware-configuration.nix as needed.
#   3. Add the hostname to this mapping.
{
  tianxuan = "x86_64-linux";
  aliyun-01 = "x86_64-linux";
}
