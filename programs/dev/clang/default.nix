{
  lib,
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ (lib.setPrio 20 pkgs.clang) ];
  };
}
