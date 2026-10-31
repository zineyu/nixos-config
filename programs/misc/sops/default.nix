{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.sops;
in
{
  options.zine.programs.sops.enable = lib.mkEnableOption "sops/age 秘密管理工具";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
    ];
  };
}
