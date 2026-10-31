{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.clang;
in
{
  options.zine.programs.clang.enable = lib.mkEnableOption "Clang（低优先级，避免覆盖 GCC 的 cc）";

  config = lib.mkIf cfg.enable {
    home.packages = [ (lib.setPrio 20 pkgs.clang) ];
  };
}
