{
  host,
  lib,
  ...
}:

{
  config = lib.mkIf (host.hasTag "gui") {
    programs.dbeaver.enable = true;
  };
}
