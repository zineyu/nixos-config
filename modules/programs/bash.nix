{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.bash.enable {
    home.file = {
      ".bash_profile".source = df "bash_profile";
      ".bashrc".source = df "bashrc";
      ".profile".source = df "profile";
      ".xinitrc".source = df "xinitrc";
    };
  };
}
