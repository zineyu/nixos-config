{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (host.form.pc && host.profile.personal) {
    home.packages = [ pkgs.localsend ];
  };
}
