{ lib, ... }:

{
  imports = import ../../../lib/discoverModules.nix {
    baseDir = ./.;
    inherit lib;
  };
}
