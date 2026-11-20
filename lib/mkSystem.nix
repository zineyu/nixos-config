{
  inputs,
  vars,
}:
let
  lib = inputs.nixpkgs.lib;
  extraLibs = import ../lib { inherit lib; };
  hostAxes = import ../lib/host-axes.nix;

  # Host Inventory 的条目 → 注入每个模块的 host metadata（ADR-0019）。
  #
  # Host Metadata 有四个视图，职责正交：
  #   platform —— 值的字符串 + 布尔：nixos / wsl / darwin（linux 为 nixos ∪ wsl）。
  #   form     —— 值的字符串 + 布尔：vm / laptop / pc / server。
  #   profile  —— 值的字符串 + 布尔：work / personal。
  #   tags     —— 用户手写的字符串列表；hasTag 是唯一的便捷判断入口。
  #   facts    —— 值，回答"这台机的硬件是什么"；GPU 与显示器由 inventory 必填。
  mkHost =
    hostname: host:
    let
      facts = host.facts or (throw "host `${hostname}`: inventory 缺少 facts 段（facts.gpu 必填）");
      platformValue =
        host.platform or (throw "host `${hostname}`: inventory 缺少 platform（nixos / wsl / darwin）");
      formValue = host.form or (throw "host `${hostname}`: inventory 缺少 form（vm / laptop / pc / server）");
      profileValue = host.profile or (throw "host `${hostname}`: inventory 缺少 profile（work / personal）");
      tags = host.tags or [ ];
    in
    {
      name = hostname;
      inherit (host) system;
      inherit facts tags;
      userEnvironment = host.userEnvironment or false;
      homeStateVersion = host.homeStateVersion or "26.05";

      # 三条轴都投影成“name + 全词表布尔”。模块写 host.form.pc，不写
      # host.form.name == "pc"：布尔拼错会在求值期报 attribute missing。
      platform = hostAxes.platform platformValue;
      form = hostAxes.form formValue;
      profile = hostAxes.profile profileValue;

      # tags 是用户手写的字符串，没有词表；hasTag 只负责判断，不约束拼写。
      hasTag = tag: lib.elem tag tags;
    };

  # NixOS 与 nix-darwin 共享的 Home Manager 集成配置。
  #
  # 广播-门控：这里无条件接入 base、programs 与桌面层，机器差异全部由
  # specialArgs.host 的 tags / platform / form / profile 与 facts 在各模块内部决定。
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
        (mkHomeManagerModule hostname host)
        ../hosts/${hostname}
        # 广播：所有 Darwin 模块树无条件导入，各树 default.nix 自行门控。
        ../modules/darwin
      ];
    };
}
