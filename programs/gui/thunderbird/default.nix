{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    programs.thunderbird.enable = true;
  };
}
