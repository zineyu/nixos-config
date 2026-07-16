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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
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

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      deploy-rs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hosts = import ./hosts;
      inherit (import ./lib/mkSystem.nix { inherit inputs vars; }) mkSystem;
      vars = import ./vars;
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

      checks.${system} = {
        lint =
          pkgs.runCommand "lint"
            {
              nativeBuildInputs = [
                pkgs.deadnix
                pkgs.nixfmt
                pkgs.statix
              ];
            }
            ''
              cd ${self}
              echo "Checking Nix formatting..."
              find . -type f -name '*.nix' -print0 | xargs -0 nixfmt --check
              echo "Checking for dead Nix code..."
              deadnix --fail --exclude ./hosts/tianxuan/hardware-configuration.nix .
              echo "Running statix..."
              statix check .
              touch $out
            '';
      };

      packages.${system} = {
        nix-conf =
          let
            shared = import ./lib/nix-settings.nix;
          in
          (pkgs.formats.nixConf {
            package = pkgs.nix;
            version = pkgs.nix.version;
            checkConfig = false;
          }).generate
            "nix.custom.conf"
            {
              extra-substituters = shared.substituters;
              extra-trusted-public-keys = shared.trusted-public-keys;
              extra-experimental-features = shared.experimental-features;
            };
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: hostSystem: mkSystem hostname hostSystem
      ) hosts;

      deploy = {
        user = "root";
        sshUser = "root";
        nodes.aliyun-01 = {
          hostname = "aliyun-01";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.aliyun-01;
          };
        };
      };
    };
}
