{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.buf;
in
{
  options.zine.programs.buf.enable = lib.mkEnableOption "buf Protobuf 工具链";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.buf ];
  };
}
