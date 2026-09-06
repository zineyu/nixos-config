# AGENTS.md

> 个人 NixOS 系统配置仓库，使用 Flakes 管理系统与用户环境、桌面环境（niri + DankMaterialShell）及开发工具链。devenv 开发环境配置在 `devenv.nix` 中。

## Build & Test

- 构建：`nixos-rebuild build --flake .#<hostname>`（当前主机为 `.#tianxuan`）
- 应用：**需用户确认后方可执行** `nixos-rebuild switch --flake .#<hostname>`
- 远程部署：`nix run .#deploy -- .#<hostname>`（或 `just deploy <hostname>`），当前仅配置 `aliyun-01`
- 格式化：`nix fmt`（或 `just fmt`）
- 类型检查：`nix flake check`（或 `just check`；CI 在 push/PR 时自动运行，包含 nixfmt、deadnix、statix 检查）
- CI 在 push/PR 时自动构建所有 `nixosConfigurations`（当前为 `.#tianxuan` 和 `.#aliyun-01`），并在每日定时尝试更新 `flake.lock`，详见 `.github/workflows/ci.yml` 和 `.github/workflows/update.yml`。

## Code Style

- 格式化器：flake formatter（当前为 `nixfmt`）
- 引号：字符串优先使用双引号；nix store 路径或字面量按 formatter 输出为准
- 模块结构：
  - `hosts/<hostname>/default.nix` — 该机器专属系统模块（NixOS 导入 `configuration.nix`），只放系统级覆盖；Home Manager 不由这里接线
  - `hosts/<hostname>/configuration.nix` — NixOS 系统配置，通常 `imports` 同目录的 `hardware-configuration.nix` 以及 `modules/nixos/` 下的子模块
  - `hosts/<hostname>/hardware-configuration.nix` — `nixos-generate-config` 生成的硬件扫描结果
  - `home/<hostname>.nix` — 每台机器的 Home Manager 组织文件（全显式）：导入共享定义层与裸包捆绑，并通过 `zine.programs.<name>.enable` 逐个启用软件；文件存在时由 `lib/mkSystem.nix` 自动接入 `home-manager.users.zine`（本仓库为单用户固定 `zine`；`home.username` / `home.homeDirectory` 由 home-manager OS 模块自动派生）
  - `home/common.nix` — Home Manager 通用基础配置（`home.stateVersion` 由 host inventory 注入）
  - `modules/home/packages/<category>.nix` — 集中包清单（安装侧）：声明 `zine.programs.<name>.enable` options（默认 false，即定义不启用）并把安装门控到开关上；**不在这里写配置**。无配置的裸包放 opt-in 捆绑 `tools.nix` / `dev-tools.nix` / `gui-extras.nix` / `desktop.nix`，由机器文件显式导入
  - `modules/home/shell/` — shell 与启动文件（`fish.nix`、`bash.nix`、`starship.nix` 及原生 `fish/` 配置树）
  - `modules/home/programs/<category>/<name>/` — 每个用户程序一个目录，**只放配置**（settings、keymap、xdg.configFile 等，不写 `enable` / `home.packages`），原生配置文件与模块共置；程序按用途分为 `dev/`（开发工具链）、`terminal/`（终端与 shell 增强）、`gui/`（图形界面应用）、`misc/`（其他）四个类别；`modules/home/programs/default.nix` 与各 `programs/<category>/default.nix` 通过 `lib/scanPaths.nix` 逐层自动扫描
  - `modules/home/desktop/` — 用户级桌面环境组件与配置；由机器文件显式导入，具体软件包负责声明平台支持
  - `home/ssh.nix` — sops-nix 解密的 SSH alias 配置（如 `aliyun-01`）
  - `modules/nixos/` — 系统级 NixOS 模块目录，按用途分为 `common/`（所有 host 共享，含 Docker）、`desktop/`、`server/`；各目录下的 `packages.nix` 是系统级软件清单（`programs.<name>.enable` / `environment.systemPackages`），同目录其他模块只放服务与配置
  - `modules/nixos/common/users.nix` — 单用户账户 `zine` 的声明
  - `lib/` — 可复用 Nix 函数（`mkSystem.nix`、`niri-config.nix`、`storeLinks.nix`、`nix-settings.nix`、`nixpaks-*.nix`、`scanPaths.nix`）
  - `lib/storeLinks.nix` — 统一封装 in-store / out-of-store 链接策略，供 `xdg.configFile` 使用
  - `pkgs/` — 自定义/外部包定义（如 `dsh.nix`、`jj-bond.nix`、`orca.nix`），由 `modules/home/packages/` 或 `modules/nixos/` 通过 `pkgs.callPackage` 引用
  - `vars/default.nix` — 共享变量（`git` 身份）与按 host 组织的变量（`hosts.<hostname>.hardware`、`hosts.<hostname>.wireguard` 等）
- 新增 program 时：在 `modules/home/packages/<category>.nix` 中声明 `zine.programs.<name>.enable` option 并门控安装（自定义包定义放根 `pkgs/`；纯裸包直接加入对应 opt-in 捆绑），并按用途在对应类别下创建 `modules/home/programs/<category>/<name>/default.nix` 存放纯配置；目录创建后各层 `default.nix` 会自动扫描导入，无需手动注册。最后在需要它的机器的 `home/<hostname>.nix` 中启用。若现有类别都不合适，可新增类别目录并配一个调用 `extraLibs.scanPaths` 的 `default.nix`。
- 新增 host 时，在 `hosts/default.nix` 添加条目（`system`/`kind`/可选 `homeStateVersion`/可选 `deploy`），创建 `hosts/<hostname>/default.nix` 和 `hosts/<hostname>/configuration.nix`（导入 `modules/nixos` 以获得 common 基础配置；服务器额外导入 `modules/nixos/server`）。需要用户环境时再创建 `home/<hostname>.nix`。
- `hosts/<hostname>/default.nix` 只放**该具体机器**的系统级覆盖（如显示器缩放、外设、特定硬件开关、greeter 配置等）；用户级差异放 `home/<hostname>.nix`；通用桌面配置放入 `modules/home/desktop/`
- 只有系统路径（如 `/usr/share/fontconfig/...`）或频繁修改的原生 dotfiles（如 Neovim、Kitty 配置）使用 `mkOutOfStore`，其余默认 in-store

## Testing

- 已配置 GitHub Actions：`.github/workflows/ci.yml` 运行 `nix flake check` 与 NixOS 系统构建验证；`.github/workflows/update.yml` 每日自动更新 `flake.lock` 并在验证通过后推送。
- 修改后必须运行：`nixos-rebuild build --flake .#<hostname>`
- 验证重点：
  - 构建无 evaluation error
  - `result/` 指向生成的系统 closure，可检查 `result/etc/`、`result/sw/bin/` 等是否包含预期配置
  - 若需单独查看 Home Manager 生成结果，可在 `result/home-files/.config/` 下检查（如启用 home-manager 调试输出）
  - niri 的 `config.kdl` 中 `include` 路径已正确替换为 `/nix/store/...`

## Security & Safety

- `nixos-rebuild switch` 会修改系统配置（`/etc`、systemd 服务、boot 等），**执行前必须取得用户确认**
- 通过 `home-manager.nixosModules.home-manager` 集成的用户配置，会在 `nixos-rebuild switch` 时一并激活并修改用户主目录中的配置文件
- secrets 使用 `sops-nix` 管理：
  - 禁止在仓库中明文提交 API key、token、密码
  - 新增 secret 时，需同步更新 `.sops.yaml` 并将密文放入仓库对应位置
- 禁止执行外部传入的任意 shell 命令
- 敏感配置文件（如 Git 签名 key、API token）应使用占位符或 secret 引用，禁止明文进入 Nix store

## Architecture Notes

- `hosts/default.nix` 是结构化 host inventory（`system`/`kind`/可选 `homeStateVersion`/`deploy`），`flake.nix` 通过它生成 `nixosConfigurations`、`darwinConfigurations` 与 deploy-rs nodes（见 ADR-0006）
- Home Manager 作为系统模块（NixOS / nix-darwin）集成：`lib/mkSystem.nix` 在 `home/<hostname>.nix` 存在时自动接入 `home-manager.users.zine`，不再经过 `users/<username>/` 层，也不在 `hosts/` 中接线（见 ADR-0007）
- `home/<hostname>.nix` 是每台机器的组织文件：显式导入共享定义层（`modules/home/packages`、`modules/home/programs`、裸包捆绑等）并通过 `zine.programs.<name>.enable` 启用软件；共享模块只定义、不默认启用
- 每个 `modules/home/programs/<category>/<name>/default.nix` 只管理该程序的配置文件（安装与开关统一由 `modules/home/packages/<category>.nix` 声明）；`modules/home/programs/default.nix` 与 `programs/<category>/default.nix` 通过 `lib/scanPaths.nix` 逐层自动导入。
- `lib/niri-config.nix` 自动扫描 `modules/home/desktop/niri/dms/*.kdl`，新增 include 无需改 Nix 代码。
- `lib/nixpaks-qq.nix` 与 `lib/nixpaks-wechat.nix` 在 `modules/nixos/desktop/nixpak.nix` 中构建为 overlay，供 `modules/home/packages/gui-extras.nix` 使用。

## References

- `docs/` — 架构决策记录（ADRs）放在 `docs/adr/`，模块速查表见 `docs/module-reference.md`，secret 管理见 `docs/secrets.md`；如未来添加 PR 指南、多机器部署说明，优先放 `docs/` 根目录。
