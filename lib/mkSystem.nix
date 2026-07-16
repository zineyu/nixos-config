{
  inputs,
  vars,
}:
{
  mkSystem =
    hostname: hostSystem:
    inputs.nixpkgs.lib.nixosSystem {
      system = hostSystem;
      specialArgs = { inherit inputs vars; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.dms.nixosModules.greeter
        inputs.niri.nixosModules.niri
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs vars; };
          home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        }

        ../hosts/${hostname}
      ];
    };
}
