{
  description = "Home Manager configuration for zine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    llm-agents-nix = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      hosts = import ./hosts;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkSystem =
        hostname: hostSystem:
        nixpkgs.lib.nixosSystem {
          system = hostSystem;
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            inputs.dms.nixosModules.greeter
            inputs.niri.nixosModules.niri
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
            }

            ./hosts/${hostname}
          ];
        };
    in
    {
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = [
          pkgs.findutils
          pkgs.nixfmt
        ];
        text = ''
          if [ "$#" -eq 0 ]; then
            mapfile -d "" files < <(
              find . \
                \( -path ./.git -o -path ./.jj -o -path ./result \) -prune \
                -o -type f -name '*.nix' -print0
            )
            if [ "''${#files[@]}" -gt 0 ]; then
              nixfmt "''${files[@]}"
            fi
          else
            nixfmt "$@"
          fi
        '';
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: hostSystem: mkSystem hostname hostSystem
      ) hosts;
    };
}
