{
  inputs,
}:
{
  mkSystem =
    hostname: hostSystem:
    inputs.nixpkgs.lib.nixosSystem {
      system = hostSystem;
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.dms.nixosModules.greeter
        inputs.niri.nixosModules.niri
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        }

        ../hosts/${hostname}
      ];
    };
}
