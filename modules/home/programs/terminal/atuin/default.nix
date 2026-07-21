{ ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      filter_mode = "session";
    };
  };
}
