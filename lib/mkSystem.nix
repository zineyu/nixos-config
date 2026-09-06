{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };

  # NixOS 与 nix-darwin 共享的 Home Manager 集成配置。
  mkHomeManagerModule = hostSystem: homeStateVersion: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        vars
        extraLibs
        homeStateVersion
        ;
      hostIsLinux = lib.hasSuffix "-linux" hostSystem;
    };
    home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
  };
in
{
  mkSystem =
    hostname: host:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (host) system;
      specialArgs = {
        inherit
          inputs
          vars
          extraLibs
          hostname
          ;
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        (mkHomeManagerModule host.system (host.homeStateVersion or "26.05"))
        ../hosts/${hostname}
      ];
    };

  mkDarwinSystem =
    hostname: host:
    inputs.darwin.lib.darwinSystem {
      inherit (host) system;
      specialArgs = {
        inherit
          inputs
          vars
          extraLibs
          hostname
          ;
      };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        (mkHomeManagerModule host.system (host.homeStateVersion or "26.05"))
        ../hosts/${hostname}
      ];
    };
}
