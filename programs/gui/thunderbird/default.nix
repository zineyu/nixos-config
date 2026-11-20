{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf (host.form.pc) {
    programs.thunderbird.enable = true;
  };
}
