{
  description = "Home Manager configuration for zine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      mkHome = import ./lib/mkHome.nix {
        inherit inputs nixpkgs home-manager;
      };
      hosts = import ./hosts;
    in
    {
      homeConfigurations = builtins.foldl'
        (acc: hostname:
          let
            host = hosts.${hostname};
          in
          acc // {
            "${host.username}@${hostname}" = mkHome {
              username = host.username;
              system = host.system;
              modules = [
                ./home.nix
                (./hosts + "/${hostname}.nix")
              ];
            };
          }
        )
        { }
        (builtins.attrNames hosts);
    };
}
