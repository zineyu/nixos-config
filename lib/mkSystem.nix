{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };

  # NixOS 与 nix-darwin 共享的 Home Manager 集成配置。
  mkHomeManagerModule =
    hostname: hostSystem: homeStateVersion:
    let
      # 每台机器的 Home Manager 组织文件：home/<hostname>.nix。
      # 文件存在才接入 home-manager.users.zine（如 aliyun-01 无用户环境）。
      homeFile = ../home + "/${hostname}.nix";
    in
    {
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
      };
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];

      home-manager.users = lib.mkIf (builtins.pathExists homeFile) {
        zine = import homeFile;
      };
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
        (mkHomeManagerModule hostname host.system (host.homeStateVersion or "26.05"))
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
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        (mkHomeManagerModule hostname host.system (host.homeStateVersion or "26.05"))
        ../hosts/${hostname}
      ];
    };
}
