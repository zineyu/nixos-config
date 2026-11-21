{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (host.form.pc && host.profile.personal && host.platform.linux) {
    home.packages = [ pkgs.nixpaks.qq ];
  };
}
