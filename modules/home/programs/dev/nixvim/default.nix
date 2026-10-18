{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.zine.programs.nixvim;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./core.nix
    ./plugins
  ];

  options.zine.programs.nixvim.enable = lib.mkEnableOption "Neovim (nixvim)";

  config = lib.mkIf cfg.enable {
    programs.nixvim.enable = true;
  };
}
