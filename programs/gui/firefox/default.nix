{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf (host.form.pc) {
    programs.firefox.enable = true;
  };
}
