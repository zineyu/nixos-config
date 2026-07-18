# AGENTS.md

> 个人 NixOS 系统配置仓库，使用 Flakes 管理系统与用户环境、桌面环境（niri + DankMaterialShell）及开发工具链。devenv 开发环境配置在 `flake.nix` 的 `devShells` 中。

## Build & Test

- 构建：`nixos-rebuild build --flake .#<hostname>`（当前主机为 `.#tianxuan`）
- 应用：**需用户确认后方可执行** `nixos-rebuild switch --flake .#<hostname>`
- 远程部署：`nix run .#deploy -- .#<hostname>`（或 `just deploy <hostname>`），当前仅配置 `aliyun-01`
- 格式化：`nix fmt`（或 `just fmt`）
- 类型检查：`nix flake check`（或 `just check`；CI 在 push/PR 时自动运行，包含 nixfmt、deadnix、statix 检查）
- CI 在 push/PR 时自动构建所有 `nixosConfigurations`（当前为 `.#tianxuan` 和 `.#aliyun-01`），并在每日定时尝试更新 `flake.lock`，详见 `.github/workflows/ci.yml` 和 `.github/workflows/update-lock.yml`。

## Code Style

- 格式化器：flake formatter（当前为 `nixfmt`）
- 引号：字符串优先使用双引号；nix store 路径或字面量按 formatter 输出为准
- 模块结构：
  - `hosts/<hostname>/default.nix` — 该机器专属 NixOS 模块，导入 `configuration.nix` 并声明 `home-manager.users.zine`（本仓库为单用户固定 `zine`）
  - `hosts/<hostname>/configuration.nix` — NixOS 系统配置，通常 `imports` 同目录的 `hardware-configuration.nix` 以及 `modules/nixos/` 下的子模块
  - `hosts/<hostname>/hardware-configuration.nix` — `nixos-generate-config` 生成的硬件扫描结果
  - `modules/home/default.nix` — 单用户 Home Manager 入口，设置 `home.username` / `home.homeDirectory` 并 orchestrate 共享 Home Manager 模块
  - `modules/home/common.nix` — Home Manager 通用基础配置
  - `modules/home/tools.nix` — 共享用户工具包（如 `ripgrep`、`fzf`、`just` 等），与具体程序解耦的常用 CLI 工具
  - `modules/home/shell/` — shell 与启动文件
  - `modules/home/programs/<name>/` — 每个用户程序一个目录，原生配置文件与模块共置；`modules/home/programs/default.nix` 通过 `lib/scanPaths.nix` 自动扫描
  - `modules/home/desktop/` — 用户级桌面环境组件与配置
  - `modules/home/ssh.nix` — sops-nix 解密的 SSH alias 配置（如 `aliyun-01`）
  - `modules/nixos/` — 系统级 NixOS 模块目录，按用途分为 `common/`、`desktop/`、`server/`
  - `modules/nixos/common/users.nix` — 单用户账户 `zine` 的声明
  - `lib/` — 可复用 Nix 函数（`mkSystem.nix`、`niri-config.nix`、`storeLinks.nix`、`nix-settings.nix`、`nixpaks-*.nix`、`scanPaths.nix`）
  - `lib/storeLinks.nix` — 统一封装 in-store / out-of-store 链接策略，供 `xdg.configFile` 使用
  - `vars/default.nix` — 共享变量（Git 身份、当前主机名、硬件总线 ID 等）
- 新增 program 时，在 `modules/home/programs/<name>/default.nix` 创建模块；目录创建后 `modules/home/programs/default.nix` 会自动扫描导入，无需手动注册。
- 新增 host 时，在 `hosts/default.nix` 添加条目，并创建 `hosts/<hostname>/default.nix` 和 `hosts/<hostname>/configuration.nix`。服务器通常额外导入 `modules/nixos/server`。
- `hosts/<hostname>/default.nix` 只放**该具体机器**的系统级覆盖（如显示器缩放、外设、特定硬件开关、greeter 配置等）；通用桌面配置放入 `modules/home/desktop/`
- 只有系统路径（如 `/usr/share/fontconfig/...`）或频繁修改的原生 dotfiles（如 Neovim、Kitty 配置）使用 `mkOutOfStore`，其余默认 in-store

## Testing

- 已配置 GitHub Actions：`.github/workflows/ci.yml` 运行 `nix flake check` 与 NixOS 系统构建验证；`.github/workflows/update-lock.yml` 每日自动更新 `flake.lock` 并在验证通过后推送。
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

- `hosts/default.nix` 现在是 `hostname -> system` 的显式映射，`flake.nix` 通过它生成 `nixosConfigurations`
- `modules/home/default.nix` 是 Home Manager 共享层 orchestrator，按顺序导入 `common` → `tools` → `shell` → `desktop` → `programs` → `ssh`
- Home Manager 作为 NixOS 模块集成：唯一用户 `zine` 直接通过 `home-manager.users.zine = import ../../modules/home` 接入系统配置，不再经过 `users/<username>/default.nix` 层。
- 每个 `modules/home/programs/<name>/default.nix` 管理该程序的启用、依赖和配置文件；`modules/home/programs/default.nix` 通过 `lib/scanPaths.nix` 自动导入。
- `lib/niri-config.nix` 自动扫描 `modules/home/desktop/niri/dms/*.kdl`，新增 include 无需改 Nix 代码。
- `lib/nixpaks-qq.nix` 与 `lib/nixpaks-wechat.nix` 在 `modules/nixos/desktop/nixpak.nix` 中构建为 overlay，供 `modules/home/programs/qq` 与 `modules/home/programs/wechat` 使用。

## References

- `docs/` — 架构决策记录（ADRs）放在 `docs/adr/`，模块速查表见 `docs/module-reference.md`，secret 管理见 `docs/secrets.md`；如未来添加 PR 指南、多机器部署说明，优先放 `docs/` 根目录。
