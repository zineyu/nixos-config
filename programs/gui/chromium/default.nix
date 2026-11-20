{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    programs.chromium.enable = true;
  };
}
