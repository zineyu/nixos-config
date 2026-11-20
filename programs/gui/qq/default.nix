{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf host.gates.desktop {
    home.packages = [ pkgs.nixpaks.qq ];
  };
}
