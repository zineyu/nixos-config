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
| `flake.nix` | Flake 入口，基于 flake-parts `mkFlake` 声明 inputs、formatter、checks、`packages.nix-conf`、扫描 `package.nix` 得到的自定义包、`nixosConfigurations` 和 `deploy`（开发环境 devShell 由 `devenv.nix` 提供） |
| `hosts/default.nix` | Host inventory：显式注册每台机器的 `system` / `kind` / `homeStateVersion` / `deploy`（当前为 `tianxuan`、`aliyun-01`、`macbook-air-01`） |
| `hosts/<hostname>/default.nix` | 该机器的 NixOS 模块，导入 `configuration.nix`（Home Manager 由 `lib/mkSystem.nix` 接线） |
| `hosts/<hostname>/configuration.nix` | 该机器的系统级配置，通常导入 `hardware-configuration.nix`、`modules/nixos` 与（桌面机）`modules/desktop/system` |
| `hosts/<hostname>/hardware-configuration.nix` | `nixos-generate-config` 生成的硬件扫描结果 |
| `home/<hostname>.nix` | 每台机器的开关表：导入机器专属层（如桌面层），再设 `zine.programs.*` / `zine.services.*`；基础层与 programs 由 `lib/mkSystem.nix` 接入 |
| `programs/<category>/<name>/` | 每个纯软件一个自包含目录（`zine.programs.<name>.enable`、安装、配置、可选 `package.nix` 共置），按 shell/terminal/dev/gui/misc 分类 |
| `programs/<...>/package.nix` | 自定义包配方，attr 名 = 目录名（`nix build .#<name>`），供 `nix-update --flake <name>` 与 CI 更新 |
| `modules/nixos/` | NixOS 系统模块，按 `common/`（所有 host 共享，含 Docker）、`server/` 分组 |
| `modules/darwin/` | nix-darwin 系统模块（sops、tailscale、Remote Login、mihomo） |
| `modules/desktop/home/` | 用户级桌面层（niri、DankMaterialShell、环境变量、fontconfig、图标主题、XDG 用户目录等），由需要的机器文件显式导入 |
| `modules/desktop/system/` | 桌面层的系统级部分（greetd/portal、音频、显卡、输入法、nixpak overlay、Steam），由桌面 host 显式导入 |
| `modules/base/` | 平台无关的 Home Manager 基础层：`common.nix`、`agent-skills/`、用户级 `services/`，由 `lib/mkSystem.nix` 自动接入 |
| `skills/<name>/` | Agent skill 源目录；每个目录经 Home Manager 安装到 `~/.agents/skills/<name>` |
| `lib/` | 可复用 Nix 函数（如 `mkSystem.nix`、`niri-config.nix`、`storeLinks.nix`、`nixpaks-*.nix`） |
| `vars/default.nix` | 共享变量（`git` 身份）与按 host 组织的变量（`hosts.<hostname>.*`） |
| `docs/adr/` | 架构决策记录（ADRs） |
| `docs/module-reference.md` | 模块与辅助函数速查表 |
| `docs/secrets.md` | sops-nix 与 secret 管理说明 |
| `secrets/` | `sops-nix` 加密的 secrets |
| `Justfile` | 常用命令快捷方式（`build`、`check`、`deploy`、`ssh-hosts` 等） |

## 新增内容

- **新增 program**：创建 `programs/<category>/<name>/default.nix`，声明 `zine.programs.<name>.enable` option，并用 `lib.mkIf cfg.enable` 包住安装与配置（各层 `default.nix` 通过 `scanPaths` 自动导入），最后在需要的 `home/<hostname>.nix` 开关表里启用。只安装包、无配置的叶子软件也是同样的三行模块。
- **新增自定义包**：把 `package.nix` 放进消费它的 program 目录，flake 自动暴露为 `.#<目录名>`；`nix-update` 依 `meta.position` 就地更新。
- **新增 agent skill**：创建 `skills/<name>/SKILL.md` 及所需资源；`modules/base/agent-skills` 会自动安装，无需注册。
- **新增 host**：在 `hosts/default.nix` 添加 `hostname = "system";` 映射，并创建 `hosts/<hostname>/default.nix` 和 `hosts/<hostname>/configuration.nix`（导入 `modules/nixos` 以获得 common 基础配置）。如为服务器，额外导入 `modules/nixos/server`。
- **新增 NixOS 模块**：在 `modules/nixos/` 下按类型放入 `common/` 或 `server/`；桌面相关的系统配置放 `modules/desktop/system/`。

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
