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
| `hosts/inventory.nix` | Host inventory：每台机器的 `system` / `kind` / `tags` / `userEnvironment` / `homeStateVersion` / `deploy`。**唯一的 host 差异来源**——模块全部被广播，是否生效由 `tags` 决定（当前为 `tianxuan`、`aliyun-01`、`macbook-air-01`、`work-hp-laptop`） |
| `hosts/<hostname>/default.nix` | 该机器的系统事实：导入 `hardware-configuration.nix`，只写引导器、内核、时区、secret 接线等；不写能力开关，也不导入模块树（由 `lib/mkSystem.nix` 广播） |
| `hosts/<hostname>/home.nix` | Machine File：只放机器专属的 user 级覆盖（字体大小、单机包）。是否存在由 inventory 的 `userEnvironment` 声明，不由文件推断 |
| `hosts/<hostname>/hardware-configuration.nix` | `nixos-generate-config` 生成的硬件扫描结果 |
| `programs/<category>/<name>/` | 每个纯软件一个自包含目录：模块自行声明所需能力（`gui`、`desktop`、`host.kind`，或什么都不需要），可选 `package.nix` 共置；按 shell/terminal/dev/gui/misc 分类 |
| `programs/<...>/package.nix` | 自定义包配方，attr 名 = 目录名（`nix build .#<name>`），供 `nix-update --flake <name>` 与 CI 更新 |
| `modules/host-metadata.nix` | 把 Host Inventory 条目投影为类型化的 `zine.host`（`kind`/`system`/`tags`/`userEnvironment`），登记 Tag 词表，并声明跨 tag 断言 | 广播-门控的唯一门控输入（ADR-0014 / ADR-0016） |
| `modules/nixos/` | NixOS 系统模块：`common/`（无条件基线）、`optional/`（各能力按 Tag 门控）、`server/`（`server` Tag）、`wsl.nix` / `nvidia.nix`（同名 Tag） |
| `modules/darwin/` | nix-darwin 系统模块：`default.nix` 广播，sops 恒启用，tailscale / Remote Login 按 Tag 挂载 |
| `modules/mihomo/` | mihomo 代理：跨平台系统模块，`config.yaml` 一份配置 + `darwin.nix`（launchd）/ `nixos.nix`（systemd），由两个平台树按 `mihomo` Tag 挂载 |
| `modules/desktop/home/` | 用户级桌面层（niri、DankMaterialShell、环境变量、fontconfig、图标主题、XDG 用户目录等），被广播，按 `desktop` Tag 生效 |
| `modules/desktop/system/` | 桌面层的系统级部分（greetd/portal、音频、蓝牙、显卡、输入法、nixpak overlay、Steam），被广播，按 `desktop` Tag 生效 |
| `modules/base/` | 平台无关的 Home Manager 基础层：`common.nix`、`agent-skills/`、用户级 `services/`（按 Tag 门控），由 `lib/mkSystem.nix` 自动接入 |
| `skills/<command>/<name>/` | Agent skill 源目录，目录名即命令：`/refactor` 路由到 `skills/refactor/` 里的技能。`principles/` 与 `tools/` 不属于任何命令，`references/` 放共享清单。每个 skill 经 Home Manager 扁平安装到 `~/.agents/skills/<name>` |
| `programs/dev/pi/prompts/` | pi 的 prompt 模板源目录：一个 `.md` 就是一个 `/命令`，经 Home Manager 链接到 `~/.pi/agent/prompts/` |
| `lib/` | 可复用 Nix 函数（`mkSystem.nix`、`host-tags.nix`、`nix-settings.nix`、`storeLinks.nix`、`scanPaths.nix`）与 nixpak 包装器（`nixpaks-*.nix`） |
| `vars/default.nix` | 共享变量（`git` 身份）与按 host 组织的变量（`hosts.<hostname>.*`） |
| `docs/adr/` | 架构决策记录（ADRs） |
| `docs/module-reference.md` | 模块与辅助函数速查表 |
| `docs/secrets.md` | sops-nix 与 secret 管理说明 |
| `secrets/` | `sops-nix` 加密的 secrets |
| `Justfile` | 常用命令快捷方式（`build`、`check`、`deploy`、`lint-skills`、`ssh-hosts` 等） |

## 新增内容

- **新增 program**：创建 `programs/<category>/<name>/default.nix`，在模块内声明它需要的能力：`lib.mkIf host.gates.gui`、`lib.mkIf (host.kind == "nixos")` 等；**不需要任何能力的就直接写 `config = { … };`**（属于 User Environment 基线）。各层 `default.nix` 通过 `scanPaths` 自动导入，**不在 inventory 里登记**。
- **新增自定义包**：把 `package.nix` 放进消费它的 program 目录，flake 自动暴露为 `.#<目录名>`；`nix-update` 依 `meta.position` 就地更新。
- **新增 agent skill**：放入它所属命令的目录，即 `skills/<command>/<name>/SKILL.md`；跨命令的判据进 `principles/`，工具进 `tools/`。`modules/base/agent-skills` 会自动安装，无需注册。改完运行 `just lint-skills`，检查 frontmatter、命名与互引链。
- **新增命令**：在 `programs/dev/pi/prompts/` 写一个 `<name>.md`，正文第一句声明它调用的技能，再加一张 `## Routing` 表说明什么情况换用哪个技能；同名技能目录随之建立。执行 `darwin-rebuild switch` 后成为 `/<name>`。
- **新增 host**：在 `hosts/inventory.nix` 注册条目（`system` / `kind` / `tags` / 可选 `userEnvironment`），创建 `hosts/<hostname>/default.nix`（只写机器事实，导入 `hardware-configuration.nix`）。**不要写 import 列表或能力开关**：需要什么能力就给 host 打对应 Tag。需要用户环境时再创建 `hosts/<hostname>/home.nix` 并置 `userEnvironment = true`。
- **新增 Tag**：在 `lib/host-tags.nix` 加一行（它是词表的唯一来源，同时供 enum 与 `host.gates` 投影），并在模块里用 `lib.mkIf host.gates.<tag>` 门控（整棵树则在入口用 `lib.optionals host.gates.<tag>`）。
- **新增 NixOS 模块**：所有 host 都必须有的放 `modules/nixos/common/`；可按主机开关的放 `modules/nixos/optional/`（按 `host.gates.<tag>` 门控）；服务器专用放 `modules/nixos/server/`；桌面相关的系统配置放 `modules/desktop/system/`。整棵树的生效条件写在各自的 `default.nix` 里。

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
