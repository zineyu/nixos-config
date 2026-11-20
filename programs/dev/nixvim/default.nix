{
  inputs,
  ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./core.nix
    ./plugins
  ];

  config = {
    programs.nixvim.enable = true;
  };
}
