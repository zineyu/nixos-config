{ inputs, extraLibs, ... }:
{
  imports = [
    inputs.dms.nixosModules.greeter
    inputs.niri.nixosModules.niri
  ]
  ++ extraLibs.scanPaths ./.;
}
