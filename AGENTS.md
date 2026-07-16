# AGENTS.md

> 个人 NixOS 系统配置仓库，使用 Flakes 管理系统与用户环境、桌面环境（niri + DankMaterialShell）及开发工具链。devenv 开发环境配置在 `flake.nix` 的 `devShells` 中。

## Build & Test

- 构建：`nixos-rebuild build --flake .#<hostname>`（当前主机为 `.#tianxuan`）
- 应用：**需用户确认后方可执行** `nixos-rebuild switch --flake .#<hostname>`
- 格式化：`nix fmt`
- 类型检查：`nix flake check`

## Code Style

- 格式化器：flake formatter（当前为 `nixfmt`）
- 引号：字符串优先使用双引号；nix store 路径或字面量按 formatter 输出为准
- 模块结构：
  - `hosts/<hostname>/default.nix` — 该机器专属 NixOS 模块，导入 `configuration.nix` 并声明 `home-manager.users.<username>`
  - `hosts/<hostname>/configuration.nix` — NixOS 系统配置，通常 `imports` 同目录的 `hardware-configuration.nix`
  - `hosts/<hostname>/hardware-configuration.nix` — `nixos-generate-config` 生成的硬件扫描结果
  - `users/<username>/default.nix` — 用户入口，设置 `home.username` / `home.homeDirectory` 并导入共享 Home Manager 模块
  - `modules/home/common.nix` — Home Manager 通用基础配置（不再接收 `username` 参数）
  - `modules/home/tools.nix` — 共享用户工具包（如 `ripgrep`、`fzf`、`just` 等），与具体程序解耦的常用 CLI 工具
  - `modules/home/shell/` — shell 与启动文件
  - `modules/home/programs/<name>/` — 每个用户程序一个目录，原生配置文件与模块共置
  - `modules/home/desktop/` — 用户级桌面环境组件与配置
  - `modules/nixos/` — 系统级 NixOS 模块（如音频、网络、Nix 设置、用户账户等），由 `hosts/<hostname>/configuration.nix` 导入
  - `lib/` — 可复用 Nix 函数
  - `lib/storeLinks.nix` — 统一封装 in-store / out-of-store 链接策略，供 `xdg.configFile` 使用
- 新增 program 时，在 `modules/home/programs/default.nix` 中注册，并优先使用 `modules/home/programs/<name>/default.nix` 结构
- 新增 host 时，在 `hosts/default.nix` 添加条目，并创建 `hosts/<hostname>/default.nix` 和 `hosts/<hostname>/configuration.nix`
- `hosts/<hostname>/default.nix` 只放**该具体机器**的系统级覆盖（如显示器缩放、外设、特定硬件开关、greeter 配置等）；通用桌面配置放入 `modules/home/desktop/`
- 只有系统路径（如 `/usr/share/fontconfig/...`）或频繁修改的原生 dotfiles（如 Neovim、Kitty 配置）使用 `mkOutOfStore`，其余默认 in-store

## Testing

- 当前无自动化测试套件。
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
- `modules/home/default.nix` 是 Home Manager 共享层 orchestrator，按顺序导入 `common` → `tools` → `shell` → `desktop` → `programs`
- Home Manager 作为 NixOS 模块集成：每个 host module 通过 `home-manager.users.<username>` 将 `users/<username>/default.nix` 导入系统配置
- 每个 `modules/home/programs/<name>/default.nix` 管理该程序的启用、依赖和配置文件
- `lib/niri-config.nix` 自动扫描 `modules/home/desktop/niri/dms/*.kdl`，新增 include 无需改 Nix 代码

## References

- `docs/` — 架构决策记录（ADRs）放在 `docs/adr/`，如未来添加 PR 指南、多机器部署说明，优先放 `docs/` 根目录
