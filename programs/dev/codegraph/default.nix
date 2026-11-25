{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ (pkgs.callPackage ../../../pkgs/codegraph/package.nix { }) ];
  };
}
