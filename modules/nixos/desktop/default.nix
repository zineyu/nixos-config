{ inputs, extraLibs, ... }:
{
  imports = [
    inputs.dms.nixosModules.greeter
    inputs.niri.nixosModules.niri
    inputs.aagl.nixosModules.default
  ]
  ++ extraLibs.scanPaths ./.;
}
