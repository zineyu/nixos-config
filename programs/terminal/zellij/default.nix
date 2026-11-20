{
  ...
}:

{
  config = {
    programs.zellij = {
      enable = true;
      settings = import ./settings.nix;
    };
  };
}
