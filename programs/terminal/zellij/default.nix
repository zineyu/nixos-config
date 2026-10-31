{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.zellij;
in
{
  options.zine.programs.zellij.enable = lib.mkEnableOption "zellij 终端复用器";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = import ./settings.nix;
    };
  };
}
