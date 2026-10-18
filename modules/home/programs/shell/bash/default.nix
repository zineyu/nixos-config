{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.bash;
in
{
  options.zine.programs.bash.enable = lib.mkEnableOption "bash";

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;

      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
      };

      bashrcExtra = ''
        PS1='[\u@\h \W]\$ '
      '';
    };
  };
}
