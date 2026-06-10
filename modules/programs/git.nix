{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.git.enable {
    home.file.".gitconfig".source = df "gitconfig";
  };
}
