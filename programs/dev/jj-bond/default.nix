{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.jj-bond;
in
{
  options.zine.programs.jj-bond.enable = lib.mkEnableOption "jj-bond：Jujutsu TUI";

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
