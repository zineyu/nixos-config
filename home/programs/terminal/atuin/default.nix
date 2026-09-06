{ ... }:

{
  programs.atuin = {
    enableFishIntegration = true;
    settings = {
      filter_mode = "session";
    };
  };
}
