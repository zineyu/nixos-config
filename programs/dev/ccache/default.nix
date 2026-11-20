{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (host.kind == "nixos") {
    home.packages = [ pkgs.ccache ];
  };
}
