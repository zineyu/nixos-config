{ ... }:

{
  # Keep the legacy Bash startup files byte-for-byte compatible with the
  # current Home Manager generation. They are non-XDG files, so `home.file` is
  # the correct boundary here.
  home.file = {
    ".bash_profile".source = ./config/bash_profile;
    ".bashrc".source = ./config/bashrc;
    ".profile".source = ./config/profile;
  };
}
