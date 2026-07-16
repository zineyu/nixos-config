{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };
in
{
  mkSystem =
    hostname: hostSystem:
    inputs.nixpkgs.lib.nixosSystem {
      system = hostSystem;
      specialArgs = { inherit inputs vars extraLibs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs vars extraLibs; };
          home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        }

        ../hosts/${hostname}
      ];
    };
}
