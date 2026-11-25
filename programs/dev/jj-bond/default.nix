{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ (pkgs.callPackage ../../../pkgs/jj-bond/package.nix { }) ];
  };
}
