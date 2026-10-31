{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.imagemagick;
in
{
  options.zine.programs.imagemagick.enable = lib.mkEnableOption "ImageMagick 图像处理";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.imagemagick ];
  };
}
