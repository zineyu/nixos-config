{
  description = "Home Manager configuration for zine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
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

    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      let
        vars = import ./vars;
        hosts = import ./hosts/inventory.nix;
        inherit (import ./lib/mkSystem.nix { inherit inputs vars; }) mkSystem mkDarwinSystem;

        nixosHosts = inputs.nixpkgs.lib.filterAttrs (_: host: host.kind == "nixos") hosts;
        darwinHosts = inputs.nixpkgs.lib.filterAttrs (_: host: host.kind == "darwin") hosts;
        deployHosts = inputs.nixpkgs.lib.filterAttrs (_: host: host.deploy.enable or false) hosts;

        nixosConfigurations = inputs.nixpkgs.lib.mapAttrs mkSystem nixosHosts;
        darwinConfigurations = inputs.nixpkgs.lib.mapAttrs mkDarwinSystem darwinHosts;
        hostSystems = inputs.nixpkgs.lib.mapAttrs (
          hostname: host:
          if host.kind == "nixos" then
            nixosConfigurations.${hostname}.config.system.build.toplevel
          else if host.kind == "darwin" then
            darwinConfigurations.${hostname}.system
          else
            throw "Unsupported host kind '${host.kind}' for '${hostname}'"
        ) hosts;
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          { pkgs, system, ... }:
          let
            # 自定义包配方（package.nix）与消费它的模块共置，attr 名 = 目录名，
            # 例如 programs/dev/codegraph/package.nix → `codegraph`。
            # 暴露为 flake packages，供 nix-update（update-pkgs.yml）、目录内的
            # update*.sh（nix-update 依 meta.position 定位文件）与 `nix build .#<name>` 使用。
            packageRoots = [
              ./programs
              ./modules/desktop
            ];
            customPkgs = builtins.listToAttrs (
              map
                (file: {
                  name = builtins.baseNameOf (builtins.dirOf file);
                  value = pkgs.callPackage file { };
                })
                (
                  builtins.filter (path: builtins.baseNameOf path == "package.nix") (
                    pkgs.lib.concatMap pkgs.lib.filesystem.listFilesRecursive packageRoots
                  )
                )
            );
          in
          {
            # `nix run .#deploy -- .#<hostname>` 调用 deploy-rs CLI，
            # 读取顶层 `deploy` 输出中的节点定义进行远程部署
            apps.deploy = {
              type = "app";
              program = pkgs.lib.getExe inputs.deploy-rs.packages.${system}.deploy-rs;
              meta.description = "Deploy remote hosts via deploy-rs";
            };

            formatter = pkgs.writeShellApplication {
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

            # deploy-rs 的 deploy output 不是标准 flake output，nix flake check 无法
            # 识别；将其 deployChecks 合并进 checks，让 deploy profile 在 CI 中得到验证。
            # activation path 固定为 x86_64-linux，因此仅在该系统上生成 checks。
            checks =
              pkgs.lib.optionalAttrs (system == "x86_64-linux") (
                inputs.deploy-rs.lib.${system}.deployChecks inputs.self.deploy
              )
              // {
                lint =
                  pkgs.runCommand "lint"
                    {
                      nativeBuildInputs = [
                        pkgs.deadnix
                        pkgs.nixfmt
                        pkgs.statix
                        pkgs.python3
                      ];
                    }
                    ''
                      cd ${inputs.self}
                      echo "Checking Nix formatting..."
                      find . -type f -name '*.nix' -print0 | xargs -0 nixfmt --check
                      echo "Checking for dead Nix code..."
                      deadnix --fail --exclude ./hosts/tianxuan/hardware-configuration.nix .
                      echo "Running statix..."
                      statix check .
                      echo "Linting skills..."
                      python3 scripts/lint-skills.py
                      echo "Linting difference axes (ADR-0018)..."
                      python3 scripts/lint-structure.py
                      touch $out
                    '';

                # 模块级回归测试（ADR-0018）：能力必须始终来自事实。
                # 任何让 gate 与 facts 脱钩、或让 gate 关掉后仍泄漏程序的改动都会在这里失败。
                zine-difference-axes =
                  let
                    nixlib = inputs.nixpkgs.lib;
                    configOf =
                      hostname: host:
                      if host.kind == "nixos" then
                        nixosConfigurations.${hostname}.config
                      else
                        darwinConfigurations.${hostname}.config;

                    # 每台主机：派生 gate 必须等于其事实。
                    gateProblems = nixlib.concatLists (
                      nixlib.mapAttrsToList (
                        hostname: host:
                        let
                          meta = (configOf hostname host).zine.host;
                        in
                        nixlib.optional (
                          meta.gates.desktop != (meta.facts.form == "desktop")
                        ) "${hostname}: gates.desktop ≠ (facts.form == \"desktop\")"
                        ++ nixlib.optional (
                          meta.gates.server != (meta.facts.form == "server")
                        ) "${hostname}: gates.server ≠ (facts.form == \"server\")"
                        ++ nixlib.optional (
                          meta.gates.wsl != (meta.facts.form == "wsl")
                        ) "${hostname}: gates.wsl ≠ (facts.form == \"wsl\")"
                        ++ nixlib.optional (
                          meta.gates.nvidia != (builtins.elem "nvidia" meta.facts.gpu.vendors)
                        ) "${hostname}: gates.nvidia ≠ (\"nvidia\" ∈ facts.gpu.vendors)"
                        ++ nixlib.optional (
                          meta.gates.desktop && !meta.gates.gui
                        ) "${hostname}: form = \"desktop\" 必须同时有 gui"
                      ) hosts
                    );

                    # gate 关闭时程序必须完全不出现（缺席轴）。
                    desktopHome = nixosConfigurations.tianxuan.config.home-manager.users.zine;
                    wslHome = nixosConfigurations.work-hp-laptop.config.home-manager.users.zine;
                    darwinHome = darwinConfigurations.macbook-air-01.config.home-manager.users.zine;
                    hasPackage = name: home: builtins.any (p: (p.pname or "") == name) home.home.packages;
                    exclusionProblems =
                      # kitty 由 gui 门控，同时它是 fontSize knob 的载体。
                      nixlib.optional (!desktopHome.programs.kitty.enable) "tianxuan 应当有 kitty（有 gui）"
                      ++ nixlib.optional wslHome.programs.kitty.enable "work-hp-laptop 不应有 kitty（无 gui）"
                      ++ nixlib.optional (
                        !hasPackage "mihomo" darwinHome
                      ) "macbook-air-01 应当有 mihomo CLI（tag mihomo，programs/misc/mihomo 承接）"
                      ++ nixlib.optional (hasPackage "mihomo" wslHome) "work-hp-laptop 不应有 mihomo（无 mihomo tag）";

                    problems = gateProblems ++ exclusionProblems;
                  in
                  if problems != [ ] then
                    throw ("差异轴回归测试失败：\n" + nixlib.concatStringsSep "\n" problems)
                  else
                    pkgs.runCommand "zine-difference-axes" { } "touch $out";
              };

            packages =
              pkgs.lib.filterAttrs (hostname: _: hosts.${hostname}.system == system) hostSystems
              // {
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
              }
              // customPkgs;
          };

        # NOTE: 开发环境的唯一来源是 devenv.nix（见根 AGENTS.md）；此处不提供 devShells。

        flake = {
          inherit nixosConfigurations darwinConfigurations;

          # 由 host inventory 中 deploy.enable = true 的条目生成 deploy-rs nodes，
          # 新增远程主机只需在 hosts/inventory.nix 中补充 deploy 元数据。
          deploy.nodes = inputs.nixpkgs.lib.mapAttrs (hostname: host: {
            inherit (host.deploy) hostname sshUser;
            profiles.system = {
              user = "root";
              fastConnection = true;
              path =
                inputs.deploy-rs.lib.${host.system}.activate.nixos
                  inputs.self.nixosConfigurations.${hostname};
            };
          }) deployHosts;
        };
      }
    );
}
