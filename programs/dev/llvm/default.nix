{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.llvm;
in
{
  options.zine.programs.llvm.enable = lib.mkEnableOption "LLVM 工具链";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.llvm ];
  };
}
