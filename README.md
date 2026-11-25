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
| `flake.nix` | Flake 入口，基于 flake-parts `mkFlake` 声明 inputs、formatter、checks、`packages.nix-conf`、扫描 `pkgs/` 得到的自定义包、`nixosConfigurations` 和 `deploy`（开发环境 devShell 由 `devenv.nix` 提供） |
| `inventory.nix` | Host inventory：每台机器的 `system` / `platform`（nixos / wsl / darwin）/ `form`（vm / pc / server）/ `profile`（work / personal）/ `facts`（GPU、显示器，必填）/ `tags`（描述性标签）/ `userEnvironment` / `homeStateVersion` / `deploy`。**唯一的 host 差异来源**——模块全部被广播，是否生效由 `host.hasTag`、`host.platform`、`host.form`、`host.profile` 与 `host.facts` 决定（当前为 `tianxuan`、`aliyun-01`、`macbook-air-01`、`work-hp-laptop`） |
| `hosts/<hostname>/default.nix` | 该机器的系统事实：导入 `hardware-configuration.nix`，只写引导器、内核、时区、secret 接线等；不写任何软件选择，也不导入模块树（由 `lib/mkSystem.nix` 广播） |
| `hosts/<hostname>/home.nix` | Machine File（可选）：只允许 `zine.*` knob 赋值，例如字号、布局。软件归属由 `tags` 里的标签表达，硬件差异走 `facts`——文件不存在即「这台机没有程度差异」 |
| `hosts/<hostname>/hardware-configuration.nix` | `nixos-generate-config` 生成的硬件扫描结果 |
| `programs/<category>/<name>/` | 每个纯软件一个自包含目录：模块自己测试所需的前提（`gui` 标签、`host.form.pc`、`host.platform.linux`，或什么都不需要）；按 shell/terminal/dev/gui/misc 分类 |
| `pkgs/<name>/` | 自定义包配方：`package.nix`（attr 名 = 目录名，`nix build .#<name>`），自维护的 `update.sh` 与配方同居；供 `nix-update --flake <name>` 与 CI 更新。唯一例外是 pi 扩展 `pi-fff`：它构建的源码树就是自己所在的目录（`src = ./.`），因此配方留在源码旁 |
| `modules/nixos/` | NixOS 系统模块：`common/`（无条件基线，含 Docker）、`hardware/nvidia.nix`（`facts.gpu.vendors` 含 nvidia）、`platform/`（`wsl.nix` 按 `platform.wsl`、`wsl-config.nix`）、`desktop/`（桌面层的系统级部分，按 `gui` 标签）、`server/`（`form.server`） |
| `modules/darwin/` | nix-darwin 系统模块：`default.nix` 广播，`sops.nix` 恒启用 |
| `modules/home-manager/` | Home Manager 模块：`common/`（`common.nix` 兼容版本、`agent-skills/`）、`desktop/`（用户级桌面层：niri、DankMaterialShell、环境变量、fontconfig、图标主题、XDG 用户目录等，按 `gui` 标签 + `platform.linux` 生效），由 `lib/mkSystem.nix` 接入 |
| `modules/shared/` | 跨平台叶子：`sshd.nix`（`host.profile.personal`）、`tailscale/{nixos,darwin}.nix`（`host.profile.personal`）、`mihomo/{config.yaml,nixos,darwin}.nix`（`host.platform` + `host.form.pc`） |
| `skills/<command>/<name>/` | Agent skill 源目录，目录名即命令：`/refactor` 路由到 `skills/refactor/` 里的技能。`principles/` 与 `tools/` 不属于任何命令，`references/` 放共享清单。每个 skill 经 Home Manager 扁平安装到 `~/.agents/skills/<name>` |
| `programs/dev/pi/prompts/` | pi 的 prompt 模板源目录：一个 `.md` 就是一个 `/命令`，经 Home Manager 链接到 `~/.pi/agent/prompts/` |
| `overlays/` | overlay 函数：`nixpaks.nix`（`pkgs.nixpaks.*`）与它的 manifest 目录 `nixpaks/`（`common.nix`、`qq.nix`、`wechat.nix`） |
| `lib/` | 可复用 Nix 函数（`mkSystem.nix`、`host-axes.nix`、`nix-settings.nix`、`storeLinks.nix`、`scanPaths.nix`、`mkUpdateScript.nix`） |
| `vars/default.nix` | 共享身份：`git` 身份与 `ssh.zinePublicKey`。机器事实属于 `inventory.nix` 的 `facts` |
| `docs/adr/` | 架构决策记录（ADRs） |
| `docs/module-reference.md` | 模块与辅助函数速查表 |
| `docs/secrets.md` | sops-nix 与 secret 管理说明 |
| `secrets/` | `sops-nix` 加密的 secrets |
| `Justfile` | 常用命令快捷方式（`build`、`check`、`deploy`、`lint-skills`、`ssh-hosts` 等） |

## 新增内容

- **新增 program**：创建 `programs/<category>/<name>/default.nix`，在模块内测试它需要的前提：`lib.mkIf (host.hasTag "gui")`、`lib.mkIf host.platform.linux`、`lib.mkIf host.form.pc` 等；**不需要任何前提的就直接写 `config = { … };`**（属于 User Environment 基线）。各层 `default.nix` 通过 `scanPaths` 自动导入，**不在 inventory 里登记**。
- **新增设备差异**：先问它属于哪条轴（ADR-0018 / ADR-0019）——标签（这台机带哪些标签）写 `tags`，平台 / 形态 / 场景写 `platform` / `form` / `profile`，硬件（GPU、显示器）写 `facts`，程度（字号、布局）加一个 `zine.*` knob 交给 Machine File 覆盖。`python3 scripts/lint-structure.py`（`just lint-structure`）会拒绝写错轴的改动。
- **新增自定义包**：在 `pkgs/<name>/package.nix` 写配方，由消费它的模块按路径 `callPackage`，flake 自动暴露为 `.#<目录名>` 并交给 `nix-update` 依 `meta.position` 就地更新；自维护的 `update.sh` 与配方同目录。例外：构建的源码树就是自己所在目录的配方（`src = ./.`，如 `programs/dev/pi/extensions/pi-fff`）留在源码旁（ADR-0022）。
- **新增 agent skill**：放入它所属命令的目录，即 `skills/<command>/<name>/SKILL.md`；跨命令的判据进 `principles/`，工具进 `tools/`。`modules/home-manager/common/agent-skills` 会自动安装，无需注册。改完运行 `just lint-skills`，检查 frontmatter、命名与互引链。
- **新增命令**：在 `programs/dev/pi/prompts/` 写一个 `<name>.md`，正文第一句声明它调用的技能，再加一张 `## Routing` 表说明什么情况换用哪个技能；同名技能目录随之建立。执行 `darwin-rebuild switch` 后成为 `/<name>`。
- **新增 host**：在 `inventory.nix` 注册条目（`system` / `platform` / `form` / `profile` / `tags` / 可选 `userEnvironment`），创建 `hosts/<hostname>/default.nix`（只写机器事实，导入 `hardware-configuration.nix`）。**不要写 import 列表，也不要点名软件**：模块自己测试 host 的标签与轴；要哪个标签就在 `tags` 里写上它。需要用户环境时再创建 `hosts/<hostname>/home.nix` 并置 `userEnvironment = true`。
- **新增 Tag**：在该 host 的 `inventory.nix` 条目 `tags` 列表里加一个自由字符串（没有词表文件），并在模块里用 `lib.mkIf (host.hasTag "<tag>")` 测试这个标签（整棵树则在入口用 `lib.optionals (host.hasTag "<tag>")`）。平台 / 形态 / 场景不是 Tag，分别改 `lib/host-axes.nix` 与 inventory。
- **新增 NixOS 模块**：所有 NixOS host 都必须有的放 `modules/nixos/common/`；只有部分 host 需要的按它的前提选位置——两个平台都要就放 `modules/shared/`，只有一个平台就放 `modules/nixos/` 或 `modules/darwin/`，并在模块体里测试那个前提；服务器专用放 `modules/nixos/server/`；桌面相关的系统配置放 `modules/nixos/desktop/`，用户级放 `modules/home-manager/desktop/`。整棵树的生效条件写在各自的 `default.nix` 里。

## 安全与 Secrets

- `nixos-rebuild switch` 会修改系统配置，执行前请确认。
- 通过 `home-manager.nixosModules.home-manager` 集成的用户配置，会在 `switch` 时一并激活并修改用户主目录中的配置文件。
- Secrets 使用 `sops-nix` 管理，由 `secrets/` 和 `.sops.yaml` 配置。禁止在仓库中明文提交 API key、token、密码。
- 敏感配置应使用占位符或 secret 引用，禁止明文进入 Nix store。

## 代理与项目约定

代理（AI coding agents）在该仓库中工作前，请先阅读：

- `AGENTS.md` — 构建命令、代码风格、模块结构、安全注意事项。
- `GLOSSARY.md` — 项目上下文、示例对话与术语表（模块边界）。
- `docs/adr/` — 关键架构决策记录。
- `docs/module-reference.md` — 模块与辅助函数速查表。
- `docs/secrets.md` — sops-nix secret 管理流程。

## 许可

本仓库为个人配置，无特定许可。如引用，风险自负。
