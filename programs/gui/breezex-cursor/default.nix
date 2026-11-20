{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (host.hasTag "gui" && host.platform.nixos) {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
