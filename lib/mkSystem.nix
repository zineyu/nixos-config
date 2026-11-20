{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };
  hostTags = import ../lib/host-tags.nix;

  # Host Inventory 的条目 → 注入每个模块的 host metadata。
  # 缺省值集中在这里，模块不必写 `host.tags or []`。
  mkHost =
    hostname: host:
    {
      name = hostname;
      tags = host.tags or [ ];
      userEnvironment = host.userEnvironment or false;
      inherit (host) kind system;
      homeStateVersion = host.homeStateVersion or "26.05";

      # 门控投影：host.gates.<tag> 对词表内每个 tag 恒存在（未声明为 false），
      # 因此模块可以写 lib.mkIf host.gates.gui。拼错 tag 名会在求值期报
      # "attribute 'giu' missing"，而不是静默为 false。
      # 它走 specialArgs（不是 option），所以 imports 里引用也安全。
      gates = lib.genAttrs hostTags (tag: lib.elem tag (host.tags or [ ]));
    };

  # NixOS 与 nix-darwin 共享的 Home Manager 集成配置。
  #
  # 广播-门控：这里无条件接入 base、programs 与桌面层，机器差异全部由
  # specialArgs.host 的 tags 在各模块内部决定。
  #
  # 一台机器的一切都在 hosts/<hostname>/ 之下：default.nix 是系统事实，
  # home.nix 是 user 级覆盖。是否存在 User Environment 由 inventory 的
  # userEnvironment 声明，而不是由文件是否在场推断（ADR-0015）。
  mkHomeManagerModule =
    hostname: host:
    let
      fullHost = mkHost hostname host;
      homeFile = ../hosts/${hostname}/home.nix;
    in
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        inherit inputs vars extraLibs;
        inherit (fullHost) homeStateVersion;
        host = fullHost;
      };
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        ../modules/host-metadata.nix
        ../modules/base
        ../programs
        ../modules/desktop/home
      ];

      home-manager.users = lib.mkIf fullHost.userEnvironment {
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
        inherit inputs vars extraLibs hostname;
        host = mkHost hostname host;
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        ../modules/host-metadata.nix
        (mkHomeManagerModule hostname host)
        ../hosts/${hostname}
        # 广播：所有 NixOS 模块树无条件导入，各树 default.nix 自行门控。
        ../modules/nixos
      ];
    };

  mkDarwinSystem =
    hostname: host:
    inputs.darwin.lib.darwinSystem {
      inherit (host) system;
      specialArgs = {
        inherit inputs vars extraLibs hostname;
        host = mkHost hostname host;
      };
      modules = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        ../modules/host-metadata.nix
        (mkHomeManagerModule hostname host)
        ../hosts/${hostname}
        # 广播：所有 Darwin 模块树无条件导入，各树 default.nix 自行门控。
        ../modules/darwin
      ];
    };
}
