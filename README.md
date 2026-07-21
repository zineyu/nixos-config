# NixOS 个人配置

个人 NixOS 系统配置仓库，使用 Flakes 管理系统与用户环境、桌面环境（niri + DankMaterialShell）及开发工具链。

## 快速开始

构建当前主机（`.#tianxuan`）配置，但不应用：

```bash
nixos-rebuild build --flake .#tianxuan
```

应用配置（会修改系统状态，执行前请确认）：

```bash
sudo nixos-rebuild switch --flake .#tianxuan
```

远程主机（`aliyun-01`）可通过 `deploy-rs` 部署：

```bash
nix run .#deploy -- .#aliyun-01
# 或如果已安装 deploy-rs
just deploy aliyun-01
```

格式化：

```bash
nix fmt
```

类型检查：

```bash
nix flake check
```

## 开发环境

开发环境使用 [devenv](https://devenv.sh/)，配置在 `devenv.nix` 中，经 `devenv.yaml` 与 `.envrc`（devenv 官方 direnv 集成 `use devenv`）接入。进入开发环境：

```bash
direnv allow
```

开发环境包含 `nixfmt`、`deadnix`、`statix`、`sops`、`ssh-to-age`、`just`、`git`、`deploy-rs` 等工具。

## 目录结构

| 路径 | 说明 |
|------|------|
| `flake.nix` | Flake 入口，基于 flake-parts `mkFlake` 声明 inputs、formatter、checks、`packages.nix-conf`、`nixosConfigurations` 和 `deploy`（开发环境 devShell 由 `devenv.nix` 提供） |
| `hosts/default.nix` | 主机注册表，显式映射 `hostname -> system`（当前为 `tianxuan`、`aliyun-01`） |
| `hosts/<hostname>/default.nix` | 该机器的 NixOS 模块，导入 `configuration.nix` 并声明 `home-manager.users.zine` |
| `hosts/<hostname>/configuration.nix` | 该机器的系统级配置，通常导入 `hardware-configuration.nix` 和 `modules/nixos/` 模块 |
| `hosts/<hostname>/hardware-configuration.nix` | `nixos-generate-config` 生成的硬件扫描结果 |
| `modules/home/default.nix` | 单用户 Home Manager 入口，设置 `home.username` / `home.homeDirectory`，并 orchestrate 共享模块 |
| `modules/home/common.nix` | Home Manager 通用基础配置 |
| `modules/home/tools.nix` | 日常通用 CLI 工具（如 `ripgrep`、`fzf`、`just` 等）；语言/编译器/构建工具见 `programs/devtools/` |
| `modules/home/shell/` | 用户 shell 与启动文件（`fish.nix`、`bash.nix`、`starship.nix` 及原生 `fish/` 配置树） |
| `modules/home/desktop/` | 用户级桌面环境组件（niri、DankMaterialShell、环境变量、fontconfig、图标主题、XDG 用户目录等） |
| `modules/home/programs/<name>/` | 每个用户程序一个目录，原生配置文件与模块共置 |
| `modules/home/ssh.nix` | 用 sops-nix 解密并生成 SSH alias 配置（如 `aliyun-01`） |
| `modules/nixos/` | 系统级 NixOS 模块，按 `common/`（所有 host 共享，含 Docker）、`desktop/`、`server/` 分组 |
| `lib/` | 可复用 Nix 函数（如 `mkSystem.nix`、`niri-config.nix`、`storeLinks.nix`、`nixpaks-*.nix`） |
| `vars/default.nix` | 共享变量（`git` 身份）与按 host 组织的变量（`hosts.<hostname>.*`） |
| `docs/adr/` | 架构决策记录（ADRs） |
| `docs/module-reference.md` | 模块与辅助函数速查表 |
| `docs/secrets.md` | sops-nix 与 secret 管理说明 |
| `secrets/` | `sops-nix` 加密的 secrets |
| `Justfile` | 常用命令快捷方式（`build`、`check`、`deploy`、`ssh-hosts` 等） |

## 新增内容

- **新增 program**：在 `modules/home/programs/<name>/default.nix` 创建模块，放入对应目录后会由 `modules/home/programs/default.nix` 通过 `scanPaths` 自动导入。
- **新增 host**：在 `hosts/default.nix` 添加 `hostname = "system";` 映射，并创建 `hosts/<hostname>/default.nix` 和 `hosts/<hostname>/configuration.nix`（导入 `modules/nixos` 以获得 common 基础配置）。如为服务器，额外导入 `modules/nixos/server`。
- **新增 NixOS 模块**：在 `modules/nixos/` 下按类型放入 `common/`、`desktop/` 或 `server/`，并由对应 `default.nix` 自动扫描，或显式导入到主机的 `configuration.nix` 中。

## 安全与 Secrets

- `nixos-rebuild switch` 会修改系统配置，执行前请确认。
- 通过 `home-manager.nixosModules.home-manager` 集成的用户配置，会在 `switch` 时一并激活并修改用户主目录中的配置文件。
- Secrets 使用 `sops-nix` 管理，由 `secrets/` 和 `.sops.yaml` 配置。禁止在仓库中明文提交 API key、token、密码。
- 敏感配置应使用占位符或 secret 引用，禁止明文进入 Nix store。

## 代理与项目约定

代理（AI coding agents）在该仓库中工作前，请先阅读：

- `AGENTS.md` — 构建命令、代码风格、模块结构、安全注意事项。
- `CONTEXT.md` — 项目术语与模块边界。
- `docs/adr/` — 关键架构决策记录。
- `docs/module-reference.md` — 模块与辅助函数速查表。
- `docs/secrets.md` — sops-nix secret 管理流程。

## 许可

本仓库为个人配置，无特定许可。如引用，风险自负。
