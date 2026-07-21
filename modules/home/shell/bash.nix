{ ... }:

{
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
}
