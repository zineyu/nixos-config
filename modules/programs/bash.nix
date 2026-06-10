{ df, ... }:

{
  home.file = {
    ".bash_profile".source = df "bash_profile";
    ".bashrc".source = df "bashrc";
    ".profile".source = df "profile";
    ".xinitrc".source = df "xinitrc";
  };
}
