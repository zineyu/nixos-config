{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.npm.enable {
    home.file.".npmrc".source = df "npmrc";
  };
}
