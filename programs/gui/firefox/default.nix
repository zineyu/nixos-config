{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    programs.firefox.enable = true;
  };
}
