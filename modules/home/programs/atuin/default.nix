{ ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      filter_mode = "directory";
    };
  };
}
