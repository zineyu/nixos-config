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
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
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
                ./home/common
                ./home/users/${host.username}
                ./home/hosts/${hostname}
              ];
              inherit outputs;
            };
          }
        )
        { }
        (builtins.attrNames hosts);
    };
}
