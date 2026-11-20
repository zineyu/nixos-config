{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (host.form.pc) {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
