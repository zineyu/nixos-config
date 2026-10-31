{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.bitwarden-cli;
in
{
  options.zine.programs.bitwarden-cli.enable = lib.mkEnableOption "Bitwarden CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bitwarden-cli ];
  };
}
