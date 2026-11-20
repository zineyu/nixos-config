{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf host.gates.gui {
    programs.vscode.enable = true;
  };
}
