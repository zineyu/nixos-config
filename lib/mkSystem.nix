{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };
  hostTags = import ../lib/host-tags.nix;

  # Host Inventory 的条目 → 注入每个模块的 host metadata（ADR-0018）。
  #
  # Host Metadata 只有两个视图，职责正交：
  #   gates —— 布尔，回答"这台机有没有这个能力"；对词表恒存在，拼错即求值失败。
  #   facts —— 值，回答"这台机的硬件是什么"；形态与 GPU 等事实由 inventory 必填。
  # tags 不进入 Host Metadata：它是 inventory 的输入语法，模块看不到"来源"，
  # 只看得到推导结果（审计视图仍可经 zine.host.tags 查看）。
  mkHost =
    hostname: host:
    let
      facts = host.facts or (throw "host `${hostname}`: inventory 缺少 facts 段（facts.form 与 facts.gpu 必填）");
      tags = host.tags or [ ];

      declared = lib.genAttrs hostTags.chosen (tag: lib.elem tag tags);

      # 推导的能力：事实决定，不可声明。
      derived = {
        desktop = facts.form == "desktop";
        server = facts.form == "server";
        wsl = facts.form == "wsl";
        nvidia = lib.elem "nvidia" (facts.gpu.vendors or [ ]);
      };
    in
    {
      name = hostname;
      inherit (host) kind system;
      inherit facts;
      userEnvironment = host.userEnvironment or false;
      homeStateVersion = host.homeStateVersion or "26.05";

      # 门控投影：对词表内每个能力恒存在（未命中为 false），因此模块可以写
      # lib.mkIf host.gates.gui。拼错会在求值期报 "attribute 'giu' missing"，
      # 而不是静默为 false。它走 specialArgs（不是 option），所以 imports 里
      # 引用也安全；但按 ADR-0018，imports 保持无条件，门控写进模块体。
      gates = declared // derived;
    };

  # NixOS 与 nix-darwin 共享的 Home Manager 集成配置。
  #
  # 广播-门控：这里无条件接入 base、programs 与桌面层，机器差异全部由
  # specialArgs.host 的 gates 与 facts 在各模块内部决定。
  #
  # 一台机器的一切都在 hosts/<hostname>/ 之下：default.nix 是系统事实，
  # home.nix 是可选的 user 级 knob 覆盖（不存在即无覆盖）。是否存在
  # User Environment 由 inventory 的 userEnvironment 声明，不由文件是否在场推断
  # （ADR-0015 / ADR-0018）。
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
        # Machine File 是可选的：绝大多数主机没有 user 级差异，不该被迫留一个
        # 空模块（ADR-0018）。文件不在场等价于没有覆盖。
        zine = if builtins.pathExists homeFile then import homeFile else { };
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
        inherit
          inputs
          vars
          extraLibs
          hostname
          ;
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
