{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
