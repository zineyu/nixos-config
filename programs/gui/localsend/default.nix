{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    home.packages = [ pkgs.localsend ];
  };
}
