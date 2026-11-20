{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    programs.dbeaver.enable = true;
  };
}
