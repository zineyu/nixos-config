{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.rustup;
in
{
  options.zine.programs.rustup.enable = lib.mkEnableOption "rustup Rust 工具链";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rustup ];
  };
}
