{ ... }:

{
  programs.atuin = {
    enableFishIntegration = true;
    settings = {
      filter_mode = "session";
      keymap_mode = "vim";
    };
  };
}
