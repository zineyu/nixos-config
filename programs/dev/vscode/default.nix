{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf (host.hasTag "gui") {
    programs.vscode.enable = true;
  };
}
