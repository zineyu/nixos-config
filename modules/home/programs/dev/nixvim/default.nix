{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./core.nix
    ./plugins
  ];
  programs.nixvim.enable = true;
}
