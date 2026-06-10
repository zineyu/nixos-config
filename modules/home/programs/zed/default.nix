{ ... }:

{
  programs.zed-editor.enable = true;

  xdg.configFile."zed" = {
    source = ./config;
    recursive = true;
  };
}
