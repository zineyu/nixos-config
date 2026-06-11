{
  description = "Home Manager configuration for zine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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

  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      mkHome = import ./lib/mkHome.nix {
        inherit inputs nixpkgs home-manager;
      };
      hosts = import ./hosts;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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

      homeConfigurations = builtins.foldl' (
        acc: hostname:
        let
          host = hosts.${hostname};
        in
        acc
        // {
          "${host.username}@${hostname}" = mkHome {
            inherit hostname;
            username = host.username;
            system = host.system;
            modules = [
              ./users/${host.username}
            ]
            ++ (host.modules or [ ]);
          };
        }
      ) { } (builtins.attrNames hosts);
    };
}
