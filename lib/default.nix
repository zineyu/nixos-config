{ lib }:
{
  inherit (import ./scanPaths.nix { inherit lib; }) scanPaths;
}
