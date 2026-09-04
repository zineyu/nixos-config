{ inputs, extraLibs, ... }:
{
  imports = [
    inputs.dank-greeter.nixosModules.default
    inputs.niri.nixosModules.niri
    inputs.aagl.nixosModules.default
  ]
  ++ extraLibs.scanPaths ./.;
}
