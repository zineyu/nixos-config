# Module Reference

本文件是仓库中 NixOS / Home Manager 模块与辅助函数的速查表。新增、删除或重命名模块时，请同步更新本文件。

仓库的顶层分工：

| 目录 | 职责 |
|------|------|
| `programs/` | 纯软件：每个程序一个自包含 Home Manager 模块目录，模块自己测试所需前提（`gui` 标签 / `form.pc` / `platform.linux`），无需前提者为基线 |
| `pkgs/` | 自定义包配方：每包一个 `pkgs/<name>/`，含 `package.nix` 与可选的自维护 `update.sh`；flake 暴露为 `.#<name>`（ADR-0022） |
| `modules/` | 系统侧与 user 侧配置：`nixos/`、`darwin/`（按平台），`home-manager/`（平台无关 HM 层，含 `common/` 与 `desktop/`），`shared/`（跨平台叶子） |
| `overlays/` | overlay 函数：`nixpaks.nix`（`pkgs.nixpaks.*`）与其 manifest 目录 `nixpaks/` |
| `lib/` | 通用辅助函数（`mkSystem`、`host-axes`、`scanPaths`、`storeLinks`、`nix-settings`、`mkUpdateScript`） |
| `inventory.nix` | Host Inventory：**唯一**的 host 差异来源（见 [Registry & Entry Points](#registry--entry-points)） |
| `hosts/<hostname>/` | 该机器的一切：`default.nix`（系统事实）、`home.nix`（user 级覆盖，可选）、`hardware-configuration.nix` |

---

## Composition & Host Metadata

### Host Metadata（`lib/mkSystem.nix` 注入的 `host`）

广播-门控（ADR-0014 / ADR-0019）的唯一门控输入。`lib/mkSystem.nix` 把 Host Inventory
的条目经 `specialArgs.host` 注入每个模块，把三条轴投影成布尔，并把 `tags` 投影成
`host.hasTag`。

| 视图 | 形状 | 消费方式 |
|------|------|---------|
| `host.platform.<值>` | 布尔：`nixos` / `wsl` / `darwin`；`linux` = `nixos ∪ wsl`；`name` 为精确值 | 模块门控：`lib.mkIf host.platform.linux` |
| `host.form.<值>` | 布尔：`vm` / `pc` / `server`；`name` 为精确值 | 模块门控：`lib.mkIf host.form.pc` |
| `host.profile.<值>` | 布尔：`work` / `personal`；`name` 为精确值 | 模块门控：`lib.mkIf host.profile.work` |
| `host.hasTag "<tag>"` | 谓词：`tag` 是否在该 host 的 `tags` 列表里 | 模块门控：`lib.mkIf (host.hasTag "gui")`；树入口另见 `lint-allow-imports-gate` |
| `host.facts` | 值：`gpu{vendors,prime}` / `displays` | 喂 knob 的默认值；inventory 必填 |

门控表达式必须读 `specialArgs.host`，不能读 `config`：`imports` 在模块收集
阶段求值，引用 `config` 会无限递归。反过来，`imports` 保持无条件（ADR-0018）——门控写
进模块体，这样每台主机都会求值每个模块。

### 差异表达与门禁

| 轴 | 判据 | 出口 | 机检 |
|----|------|------|------|
| 平台 / 形态 / 场景 | 机器的固定属性 | `inventory.nix` 的 `platform` / `form` / `profile` | R5：每个 host 必须写全 |
| 事实 | 值来自世界 | `inventory.nix` 的 `facts` | R5：每个 host 必须有 `facts.gpu` |
| 标签 | 这台机是什么（描述，不是开关） | `tags`（自由字符串） | `host.hasTag "<tag>"` |
| 程度 | 有默认值，这台想不一样 | 模块内的 `zine.*` knob | R4：knob 必须有 default；R3：Machine File 只碰 `zine.*` |

`scripts/lint-structure.py`（`just lint-structure`，也挂在 `checks.x86_64-linux.lint`）
实现 R1–R5：R1 模块禁 hostname 分支、R2 imports 不得引用 host metadata、
R3 Machine File 只允许 `zine.*`、R4 knob 必须有 default、R5 inventory 必须写全三条轴
与 `facts.gpu`。

### `lib/mkSystem.nix` 的广播

| 平台 | 无条件导入 |
|------|-----------|
| NixOS / WSL | `../hosts/<hostname>`、`../modules/nixos` |
| Darwin | `../hosts/<hostname>`、`../modules/darwin` |
| Home Manager（两侧共用） | `../modules/home-manager`（`common/` + `desktop/`）、`../programs` |

## NixOS System Modules

### `modules/nixos/common/`

所有 NixOS host 无条件共享的基线系统配置。只放“每台 NixOS 机器都必须有”的内容；
只有部分 host 需要的模块放在它前提所指的那棵树里，并在模块体内自门控（见
[Cross-platform System Modules](#cross-platform-system-modules)）。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入同级 `.nix` 文件。 | `extraLibs.scanPaths` |
| `docker.nix` | Docker 守护进程与 `docker` 组；每台 NixOS host 都启用。 | `virtualisation.docker`；`users.users.zine.extraGroups` |
| `i18n.nix` | 设置系统 locale 为简体中文。 | `i18n.defaultLocale = "zh_CN.UTF-8"` |
| `nix.nix` | 共享 Nix daemon 设置，并声明 `trusted-users`。 | 导入 `lib/nix-settings.nix`；允许 unfree |
| `packages.nix` | 系统级软件清单（所有 host 共享）：fish、vim、wget。 | `environment.systemPackages` |
| `users.nix` | 定义单用户 `zine`、用户组与登录 shell，并声明其 OpenSSH 授权公钥。 | `wheel`、`video`、`render`；shell = fish；`vars.ssh.zinePublicKey` |

`modules/nixos/common/packages.nix` 是系统级软件清单：只放 `programs.<name>.enable` 与 `environment.systemPackages`，配置放同目录其他模块。

`boot.kernelPackages` 与引导加载器一样属于主机属性，放在 `hosts/<hostname>/`，
不放共享基线（WSL 依赖 Windows 提供的内核）。

### `modules/nixos/server/`

常驻服务器的系统服务。整棵树被所有 NixOS host 导入，只有 `form = "server"` 的 host
生效（`default.nix` 内的 `lib.optionals host.form.server` 门控）。tailscale 与 sshd
见 [Cross-platform System Modules](#cross-platform-system-modules)。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入同级 `.nix` 文件。 | `extraLibs.scanPaths` |
| `atuin.nix` | 自托管 atuin shell 历史同步服务器（pgsql 后端 + Nginx + ACME）。 | `services.atuin`（127.0.0.1:8888，反代 `atuin.zineyu.cn`）；`openRegistration` 注册后需关闭 |
| `fail2ban.nix` | 启用 fail2ban 入侵防护。 | `services.fail2ban` |
| `gotify.nix` | Gotify 推送服务，供 CI 通知使用。 | `services.gotify` |
| `headscale.nix` | 自托管 Headscale 控制面 + 内嵌 DERP/STUN + 每日状态快照（ADR-0008）。 | `services.headscale`（127.0.0.1:8085，反代 `hs.zineyu.cn`）、MagicDNS `ts.zineyu.cn`、STUN UDP 3478、`/var/lib/headscale-backup` 快照 |
| `headplane.nix` | headscale 的 Web 管理界面（Headplane），仅 tailnet 内可达。 | `services.headplane`（0.0.0.0:3000，防火墙不放行公网）；API key 登录；`sops.secrets.headplane_cookie_secret` |
| `luogo_checkin.nix` | 自定义 NixOS 模块与 systemd timer，用于 Luogu 每日签到。 | 从 GitHub 构建 Go 包；`systemd.services.luogo_checkin` |
| `networking.nix` | 服务器防火墙，允许 SSH 与 HTTP/HTTPS 端口及 Headscale STUN。 | `allowedTCPPorts = [ 22 80 443 ]`、`allowedUDPPorts = [ 3478 ]` |
| `nginx.nix` | 反向代理与 ACME 证书配置。 | `services.nginx`、`security.acme` |
| `postgresql.nix` | 独立管理的 PostgreSQL 17 实例，供本机服务复用。 | `services.postgresql`；仅 unix socket；大版本升级需手动迁移 |
| `vaultwarden.nix` | Vaultwarden 密码管理服务（pgsql 后端 + Nginx + ACME）。 | `services.vaultwarden`；`sops.secrets.vaultwarden`（ADMIN_TOKEN） |

### `modules/nixos/platform/` 与 `modules/nixos/hardware/`

| File | Purpose | Gate |
|------|---------|------|
| `platform/wsl.nix` | 拉入 `nixos-wsl` 模块 | `platform.wsl` |
| `platform/wsl-config.nix` | 设 `wsl.enable` / `defaultUser`，禁用 getty 与 autovt；只随 `nixos-wsl` 模块一起导入 | 由 `platform/wsl.nix` 条件导入 |
| `hardware/nvidia.nix` | NVIDIA Optimus / PRIME offload，PCI bus id 取自 `facts.gpu.prime` | `facts.gpu.vendors` 含 `nvidia` |

### `modules/nixos/desktop/`

桌面子系统的系统级部分（NixOS 模块）。整棵树被 `modules/nixos/default.nix` 无条件
导入，只有带 `gui` 标签的 host 才真正拉入第三方模块与下列文件；第三方模块
（dank-greeter、`niri`、`aagl`）的断言无法内部关闭，因此整棵按 gate 导入而不是逐文件
门控。用户级部分见 `modules/home-manager/desktop/`。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 显式导入下列模块，并引入 dank-greeter、`niri` 与 `aagl` flake 模块。 | 显式 imports（不同类型模块不混扫） |
| `audio.nix` | 启用 PipeWire 音频。 | `services.pipewire` |
| `bluetooth.nix` | 启用 BlueZ（`hardware.bluetooth`）。 | 内核已检测到 hci0；不启用则桌面客户端报“无适配器” |
| `desktop.nix` | 配置 greetd、niri、libinput 与 xdg-portal。 | `programs.niri`、`services.greetd`、`xdg.portal` |
| `graphics.nix` | NVIDIA 专有驱动设置。 | `hardware.nvidia`、modesetting、powerManagement |
| `input-method.nix` | 启用 Fcitx5 + Rime 输入法，含小鹤音形方案。 | `fcitx5-rime`、`rime-ice`、`pkgs/rime-flypy` 配方、wayland 前端 |
| `networking.nix` | 桌面网络管理器与防火墙配置。 | `networking.networkmanager`；防火墙已关闭 |
| `nixpak.nix` | 把 `overlays/nixpaks.nix` 挂进 `nixpkgs.overlays`，产出 `pkgs.nixpaks.{qq,wechat}`，供 `programs/gui/{qq,wechat}` 消费。 | `nixpkgs.overlays`；overlay 本体与 manifest 在 `overlays/`；依赖 Home Manager 作为 NixOS 模块集成（`useGlobalPkgs`） |
| `packages.nix` | 桌面系统级软件清单：Steam、An Anime Game Launcher、KDE Connect。 | `programs.steam`、`programs.anime-game-launcher`、`programs.kdeconnect` |
| `steam.nix` | Steam 与 gamescope 的图形支持。 | `hardware.graphics.enable32Bit`；防火墙整体禁用，未单独开放端口 |

---

## nix-darwin System Modules

### `modules/darwin/`

Darwin host 的系统级模块。整棵树被 `lib/mkSystem.nix` 无条件导入，`default.nix` 无条件
导入各子树，由每个模块自己按 `host.hasTag` 门控。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 广播入口：无条件导入 `sops.nix` 与 `../shared/` 的 Darwin 叶子，由各叶子自行门控。 | `../shared/tailscale/darwin.nix`（profile）、`../shared/sshd.nix`（profile）、`../shared/mihomo/darwin.nix`（platform） |
| `sops.nix` | Darwin host 的 sops-nix 基础配置（age identity rootfs 副本）。 | `/var/lib/sops-nix/key.txt` |

---

## Cross-platform System Modules

### `modules/shared/sshd.nix`

OpenSSH 服务端只有一个实现：`modules/nixos/default.nix` 与 `modules/darwin/default.nix`
都无条件导入它，由模块体按 `host.profile.personal` 门控。两个平台的 `services.openssh`
都接受 `enable` 与 `extraConfig`，所以不需要平台叶子。

`extraConfig` 声明 `PasswordAuthentication no`、`KbdInteractiveAuthentication no`、
`PermitRootLogin prohibit-password`，再用
`Match Address *,!100.64.0.0/10,!fd7a:115c:a1e0::/48` + `DenyUsers *` 拒绝非 tailnet 来源。
NixOS 把 `extraConfig` 接在 `settings` 之后，`Match` 因此位于文件末尾；nix-darwin 把它写进
`/etc/ssh/sshd_config.d/100-nix-darwin.conf`，由 macOS 自带的 `sshd_config` 引入。

### `modules/shared/mihomo/`

mihomo（fake-IP TUN 代理）。**一份配置、两个平台的系统级模块**：配置内容只维护 `config.yaml`，平台差异（launchd vs systemd、状态目录、凭据挂载方式）留在各自的 `.nix` 里。两个叶子都在 `modules/shared/` 下，由各自的平台树（`modules/nixos/default.nix` / `modules/darwin/default.nix`）导入，并按 `host.platform` + `host.form.pc` 自门控。

| File | Purpose | Notable |
|------|---------|---------|
| `config.yaml` | 两个平台共用的 mihomo 配置（DNS、`fake-ip-filter`、规则、`proxy-providers`）。 | `path: "@proxies_file@"` 由各平台模块在构建期替换为代理凭据路径 |
| `darwin.nix` | macOS：root LaunchDaemon 跑 mihomo，代理凭据取自 sops 文件并由 `SAFE_PATHS` 授权。 | 运行时状态 `/var/lib/mihomo`；`secrets/mihomo.yaml`（sops binary）；可执行文件必须经 `launchd.daemons.<name>.command` 交付 |
| `nixos.nix` | Linux：`services.mihomo`（systemd，`DynamicUser` + TUN 能力）。 | 配置与代理凭据都通过 `LoadCredential` 挂到 `/run/credentials/mihomo.service`，凭据不落全局可读路径；`SAFE_PATHS` 指向同一目录 |

两机共用同一份 `config.yaml`：`hs.zineyu.cn` 必须在 `fake-ip-filter` 内（tailscaled 控制面直连，见 ADR-0008），tailnet 流量（`100.64.0.0/10`）通过 `route-exclude-address` 绕开 TUN。

**nix-darwin 的 LaunchDaemon 可执行文件必须经 `command`（或 `script`）交付。** nix-darwin 只对这两个选项注入 `/bin/wait4path /nix/store` 包装。直接写 `serviceConfig.ProgramArguments` 会生成指向 `/nix/store` 的裸路径；开机时 launchd 启动 job 的时刻早于 `/nix` 卷挂载完成的时刻，于是报 `Missing executable detected`，把 job 置为 `service inactive`，`KeepAlive` 不再重试，服务直到手工启动之前都保持停止。`modules/shared/mihomo/darwin.nix` 与 `modules/shared/tailscale/darwin.nix` 都遵循这条约束。


### `modules/shared/tailscale/`

Headscale tailnet 接入（`hs.zineyu.cn`，见 ADR-0008）。**一份前提、两个平台的系统级模块**：
`modules/shared/` 下的两个叶子都按 `host.profile.personal` 自门控，工作机不进个人 tailnet。

| File | Purpose | Notable |
|------|---------|---------|
| `nixos.nix` | `services.tailscale`（systemd），sops preauth key 自动注册；`tailscale0` 为 trusted interface。 | `openFirewall`（UDP 41641 打洞） |
| `darwin.nix` | tailscaled LaunchDaemon + 自定义 MagicDNS 域 resolver。 | `services.tailscale`、`/etc/resolver/ts.zineyu.cn`；可执行文件必须经 `command` 交付 |

注意 fake-ip 代理共存：tailscaled 的控制连接带 fwmark，会绕过本机 mihomo TUN，所以
`hs.zineyu.cn` 必须在 mihomo 的 `fake-ip-filter` 内。

---

## Home Manager Modules

### `modules/home-manager/common/` — 平台无关的 HM 基础层

`modules/home-manager/default.nix` 是整棵 HM 树的入口，导入 `common/` 与 `desktop/`；
它由 `lib/mkSystem.nix` 通过 `home-manager.sharedModules` 接入每个用户环境。program 是否
生效**不经过这一层**：每个 Program Module 自己测试所需的前提（`gui` 标签、`host.form.pc`、
`host.platform.linux`），无条件的直接 `config = { … };` 成为基线。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 基础层聚合器：导入 `common.nix` 与 `agent-skills`。 | 由 `modules/home-manager/default.nix` 无条件导入 |
| `common.nix` | Home Manager 基础状态与自启用。 | `programs.home-manager.enable`；`home.stateVersion` 由 host inventory 注入 |
| `agent-skills/` | 自动发现仓库根目录 `skills/<command>/<name>/` 并逐项安装 agent skills。 | 每个目录必须包含 `SKILL.md`；目录名即命令，`principles/`、`tools/`、`references/` 除外；目标为 `~/.agents/skills/<name>` |

### `modules/home-manager/desktop/` — 用户级桌面层

Wayland 桌面环境与合成器配置。本层由 `modules/home-manager/desktop/default.nix` 在
`host.hasTag "gui" && host.platform.linux` 时整层导入；具体软件包负责声明平台支持。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入下列模块，并安装桌面环境包（xwayland-satellite、wl-clipboard、字体）。 | `home.packages` |
| `niri.nix` | 安装 niri 配置并启动 `xwayland-satellite` 用户服务。 | 使用 `./niri/build.nix` 校验 `config.kdl` |
| `env.nix` | Wayland/输入法会话变量与 Qt 平台主题。 | `XDG_SESSION_TYPE = wayland`、fcitx IM 变量 |
| `dank-material-shell.nix` | DankMaterialShell（DMS）shell 与 greeter 集成。 | `inputs.dms.homeModules.dank-material-shell`、`inputs.dms.homeModules.niri` |
| `fontconfig/` | 字体默认值与配置文件。 | 使用 `lib/storeLinks.nix`（in-store + out-of-store 链接） |
| `tela-icon-theme/` | Tela GTK 图标主题。 | `gtk.iconTheme` |
| `xdg-user-dirs/` | 标准 XDG 用户目录。 | `xdg.userDirs` |
| `niri/config.kdl` | niri 主配置文件，包含 `dms/*.kdl` 片段。 | 原生配置文件 |
| `dank-material-shell/settings.nix` | 生成的 DMS settings JSON。 | `xdg.configFile` |
| `dank-material-shell/zen.css` | 自定义 Zen Browser 主题 CSS。 | `xdg.configFile` |

### `programs/` — 纯软件

仓库根的软件树。每个目录 = 一个程序：模块自己测试所需的前提（`lib.mkIf (host.hasTag "gui")`、`lib.mkIf host.form.pc`、`lib.mkIf host.platform.linux` 等）；不需要任何前提的程序属于 User Environment 基线，直接写 `config = { … };`，不做门控（ADR-0016）。原生配置文件与应用共置；自定义包配方不在这里，而在 `pkgs/<name>/`（ADR-0022）。分类只按软件种类，不按平台。

各层聚合器：`programs/default.nix` 扫描分类目录，`programs/<category>/default.nix` 扫描程序目录（`extraLibs.scanPaths`）。整棵树由 `lib/mkSystem.nix` 通过 `home-manager.sharedModules` 一次性接入；没有 per-host 软件清单，一个程序属于哪台机由模块自己读 host 的标签与轴决定。

#### `programs/shell/` — shell 与提示符

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `fish/` | Fish shell：别名、vi 键位、fzf、devenv 集成与 SSH 自动 attach。 | `programs.fish`；原生配置树在 `config/` |
| `bash/` | 最小化 Bash 配置。 | `programs.bash` |
| `starship/` | Starship 提示符，含自定义 jj 模块。 | `programs.starship` |

#### `programs/terminal/` — 终端与 shell 增强

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `atuin/` | Shell 历史同步（自托管 `atuin.zineyu.cn`），集成 fish；加密密钥经 sops-nix 软链到数据目录。 | `programs.atuin`；`sops.secrets.atuin_key`（`secrets/atuin.yaml`） |
| `yazi/` | 终端文件管理器，配置拆分为 settings/keymap/theme。 | `programs.yazi` |
| `zellij/` | 终端复用器，生成 KDL 设置。 | `programs.zellij`；`settings.nix` |
| `zoxide/` | 智能目录跳转。 | `programs.zoxide` |

#### `programs/dev/` — 开发工具

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `codegraph/` | 代码知识图谱 CLI（自定义配方 + 多平台 hash 更新脚本）。 | `pkgs/codegraph/` → `.#codegraph` |
| `dbeaver/` | DBeaver 数据库客户端。 | `programs.dbeaver` |
| `devenv/` | devenv shell 集成。 | `programs.devenv` |
| `dsh/` | dsh 编码 Agent（来自 `llm-agents-nix`）。 | `inputs.llm-agents-nix` |
| `fabric/` | fabric 自定义 patterns（commit/PR/分支名生成）与 `fabric-ai` 包。 | `xdg.configFile`，单文件链接 |
| `git/` | Git 配置，含 GPG 签名与 LFS。 | `programs.git` |
| `jj/` | Jujutsu 版本控制，含 GPG 签名。 | `programs.jujutsu` |
| `jj-bond/` | Jujutsu TUI（自定义配方）。 | `pkgs/jj-bond/` → `.#jj-bond` |
| `mise/` | mise 运行时管理器，集成 fish。 | `programs.mise` |
| `nixvim/` | Neovim 编辑器（nixvim），核心与插件配置拆分。 | `inputs.nixvim.homeModules.nixvim`；`core.nix`、`plugins/` |
| `npm/` | npm prefix 配置。 | `programs.npm` |
| `pi/` | pi 编码 Agent；扩展与提示词是仓库内源码（`extensions/`、`prompts/`），逐个链接进 `~/.pi/agent/`。 | `inputs.pi`、`home.file`；`extensions/pi-vcc/` 取自上游 `sting8k/pi-vcc`，`extensions/pi-bg-bash/` 取自上游 `gvanderclay/pi-bg-bash`，`extensions/pi-btw/` 取自上游 `dbachelder/pi-btw`（其技能落在 `skills/tools/btw/`），`extensions/pi-notify/` 取自上游 `bacnh85/pi-extensions` 的 `pi-notify`，`extensions/pi-fff/` 取自同一仓库的 `pi-fff`（带 npm 运行时依赖，由 `package.nix` → `.#pi-fff` 构建后链接），`extensions/pi-jj/` 取自上游 `manojlds/pi-jj`（只保留 checkpoints 与 onboarding） |
| `vscode/` | VS Code。 | `programs.vscode` |
| `zed/` | Zed 编辑器，含 GLM 模型与 vim 键位。 | `programs.zed-editor` |

只安装包的开发工具叶子模块（每个模块自行门控，`ccache`/`mold` 仅 NixOS）：`buf`、`bun`、`ccache`（Linux-only 构建输入）、`clang`（低优先级）、`cmake`、`dart-sass`、`gcc`、`github-cli`、`gnumake`、`go`、`lazygit`、`lazyjj`、`llvm`、`maven`、`mold`（仅 Linux）、`ninja`、`pip`、`python3`、`rustup`、`stylua`、`tree-sitter`、`uv`。

#### `programs/gui/` — 图形界面应用

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `breezex-cursor/` | BreezeX 光标主题包（自定义配方）。 | `pkgs/breezex-cursor/` → `.#breezex-cursor` |
| `chromium/` | Chromium。 | `programs.chromium` |
| `cursor/` | 指针主题配置（消费 `breezex-cursor`）。 | `home.pointerCursor` |
| `dbx-desktop/` | DBX Desktop（自定义配方 + FOD hash 更新脚本）。 | `pkgs/dbx-desktop/` → `.#dbx-desktop` |
| `dolphin/` | KDE Dolphin 安装与默认目录关联。 | `xdg.mimeApps` |
| `firefox/` | Firefox。 | `programs.firefox` |
| `kitty/` | Kitty 图形终端，含主题与自定义配置；`zine.programs.kitty.fontSize` 是程度轴 knob。 | `programs.kitty`；`lib/storeLinks.nix`（`mkOutOfStoreDotfiles`，指向 `programs/gui/kitty/config/`） |
| `qbittorrent/` | qBittorrent（GUI BitTorrent 客户端），接管磁力链接与 `.torrent` 默认打开方式。 | `home.packages`；`xdg.mimeApps`（配置由应用自身维护在 `~/.config/qBittorrent/`） |
| `qq/` | QQ（nixpak 沙盒，消费 `overlays/nixpaks.nix` 经 `modules/nixos/desktop/nixpak.nix` 挂上的 `pkgs.nixpaks`）。 | `pkgs.nixpaks.qq` |
| `thunderbird/` | Thunderbird。 | `programs.thunderbird` |
| `wechat/` | 微信（nixpak 沙盒）。 | `pkgs.nixpaks.wechat` |
| `zen-browser/` | Zen Browser，使用自定义 unwrapped 包与策略。 | `inputs.zen-browser.homeModules.default`；Darwin 上重签名 |

只安装包的 GUI 叶子模块：`localsend`。

#### `programs/misc/` — 其他

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `gnupg/` | GnuPG、gpg-agent 与 SSH agent，通过 sops-nix 导入私钥。 | `programs.gpg`、`services.gpg-agent`、自定义导入服务 |
| `karabiner-elements/` | Karabiner-Elements 键盘配置（Darwin）。 | 包由 Homebrew cask 安装；`xdg.configFile` |
| `rime-ice/` | Rime Ice（雾凇拼音）输入法与 Squirrel 前端（Darwin）。 | `home.file`、`home.activation`；`pkgs/squirrel/` → `.#squirrel` |
| `sops/` | sops 与 age 命令行工具。 | `home.packages` |
| `ssh/` | SSH 客户端配置：sops 渲染的公网主机（如 `aliyun-01`）+ tailnet 成员别名 + 公钥授权。 | `sops.templates.ssh-hosts`、`~/.ssh/authorized_keys`（`vars.ssh.zinePublicKey`） |

只安装包的通用 CLI 叶子模块（属 User Environment 基线，不门控）：`bat`、`bitwarden-cli`、`btop`、`chafa`、`chezmoi`、`curl`、`eza`、`fastfetch`、`fd`、`fzf`、`hugo`、`imagemagick`、`jq`、`just`、`lnav`、`ncdu`、`nvtop`、`pandoc`、`pigz`、`resvg`、`ripgrep`、`stow`、`trash-cli`、`tree`、`unzip`、`websocat`、`zip`。

---

## Package Recipes

自定义包集中在 `pkgs/<name>/`：一个目录 = 一个包，`package.nix` 旁边可以放自维护的 `update.sh`。`flake.nix` 扫描 `pkgs/`（外加 `programs/dev/pi/extensions/`，见下表的 `pi-fff`），**attr 名 = 目录名**；消费方按路径 `callPackage`。

| Recipe | Flake attr | 消费方 |
|--------|-----------|--------|
| `pkgs/breezex-cursor/package.nix` | `#breezex-cursor` | `programs/gui/{breezex-cursor,cursor}` |
| `pkgs/codegraph/{package.nix,update.sh}` | `#codegraph` | `programs/dev/codegraph/default.nix` |
| `pkgs/dbx-desktop/{package.nix,update.sh}` | `#dbx-desktop` | `programs/gui/dbx-desktop/default.nix` |
| `pkgs/jj-bond/package.nix` | `#jj-bond` | `programs/dev/jj-bond/default.nix` |
| `pkgs/rime-flypy/package.nix` | `#rime-flypy` | `modules/nixos/desktop/input-method.nix` |
| `pkgs/squirrel/package.nix` | `#squirrel` | `programs/misc/rime-ice/default.nix` |
| `programs/dev/pi/extensions/pi-fff/package.nix` | `#pi-fff` | `programs/dev/pi/default.nix` |

`pi-fff` 是唯一留在源码旁的配方：它构建的就是自己所在的扩展源码树（`src = ./.`，带 `package-lock.json`），搬走会把源码与配方拆开（ADR-0022）。

`nix-update --flake <attr>` 依 `meta.position` 定位配方文件，移动目录无需改脚本。`breezex-cursor`、`jj-bond`、`rime-flypy`、`squirrel` 的 `updateScript` 都由 `lib/mkUpdateScript.nix` 生成：它在调用 nix-update 前先 `nix flake prefetch` 把工作树复制进 store，因为 Nix 2.35 起 `nix flake metadata` 只报告路径不再复制，nix-update ≤ 1.16 会因此报 `opening file /nix/store/…-source: No such file or directory`（Mic92/nix-update#687）。`codegraph` 与 `dbx-desktop` 的更新逻辑无法由 nix-update 表达，各自带 `update.sh`；`updateScript` 会被复制进 `/nix/store`，因此脚本用 git 索引按目录名定位配方，而不是靠自身路径。

`nix-update --flake <attr>` 依 `meta.position` 定位配方文件，移动目录无需改脚本。`breezex-cursor`、`jj-bond`、`rime-flypy`、`squirrel` 的 `updateScript` 都由 `lib/mkUpdateScript.nix` 生成：它在调用 nix-update 前先 `nix flake prefetch` 把工作树复制进 store，因为 Nix 2.35 起 `nix flake metadata` 只报告路径不再复制，nix-update ≤ 1.16 会因此报 `opening file /nix/store/…-source: No such file or directory`（Mic92/nix-update#687）。`codegraph` 与 `dbx-desktop` 的更新逻辑无法由 nix-update 表达，各自带 `update.sh`；`updateScript` 会被复制进 `/nix/store`，因此脚本用 git 索引按目录名定位配方，而不是靠自身路径。

---

## Overlays

overlay 函数与它的 manifest 分开放：`overlays/` 只放 overlay 函数，`modules/` 只负责把它
挂进 `nixpkgs.overlays`，因此 `lib/` 不再持有任何包配方。

| File | Purpose | Consumers |
|------|---------|-----------|
| `overlays/nixpaks.nix` | overlay 函数：绑定 `mkNixPak`、把 `qq` 覆盖为 3.2.32，再 `callPackage` 两个 manifest，产出 `pkgs.nixpaks.{qq,wechat}`。 | `modules/nixos/desktop/nixpak.nix` |
| `overlays/nixpaks/common.nix` | 通用 nixpak 沙盒策略（GPU、DBus、bubblewrap、字体、portals）。 | `overlays/nixpaks/qq.nix`、`overlays/nixpaks/wechat.nix` |
| `overlays/nixpaks/qq.nix` | 腾讯 QQ 的 nixpak 包装器。 | `overlays/nixpaks.nix`（`pkgs.nixpaks.qq` → `programs/gui/qq`） |
| `overlays/nixpaks/wechat.nix` | 微信的 nixpak 包装器。 | `overlays/nixpaks.nix`（`pkgs.nixpaks.wechat` → `programs/gui/wechat`） |

---

## Library Helpers

可复用的 Nix 函数与构造器。overlay 见 [Overlays](#overlays)。

| File | Purpose | Consumers |
|------|---------|-----------|
| `lib/default.nix` | 暴露 `scanPaths` 辅助函数。 | 各模块的 `default.nix` |
| `lib/host-axes.nix` | 三条轴的词表与布尔投影：`platform` / `form` / `profile`。 | `mkSystem` 用作投影 |
| `lib/mkSystem.nix` | 为所有 host 构建 `nixosSystem` / `darwinSystem`（WSL 走 NixOS 路径），接入 home-manager 与 sops-nix，把 `modules/home-manager` 与 `programs` 加入 `home-manager.sharedModules`，注入 `hostname` / `host` / `homeStateVersion`（含三元轴投影与 `host.hasTag`），并在 `userEnvironment = true` 时导入 `hosts/<hostname>/home.nix` 接线 `home-manager.users.zine`。 | `flake.nix` |
| `modules/home-manager/desktop/niri/build.nix` | 构建并校验 niri 配置 derivation，包含 `dms/` 片段。 | `modules/home-manager/desktop/niri.nix` |
| `lib/nix-settings.nix` | 共享 Nix substituters、trusted public keys 与 experimental features。 | `modules/nixos/common/nix.nix`、`flake.nix` |
| `lib/scanPaths.nix` | 返回路径下所有 `.nix` 文件与子目录（排除 `default.nix`）。 | 所有 `default.nix` 模块聚合器 |
| `lib/storeLinks.nix` | 显式 in-store / out-of-store 软链接辅助函数（`mkInStore`、`mkOutOfStore`、`mkOutOfStoreDotfiles`）。 | `modules/home-manager/desktop/fontconfig`、`programs/gui/kitty` |

---

## Registry & Entry Points

| File | Purpose | Notable |
|------|---------|---------|
| `vars/default.nix` | 共享身份：`git` 身份与 zine 的 SSH 公钥。 | `git.*`、`ssh.zinePublicKey`；机器事实属于 `inventory.nix` 的 `facts` |
| `inventory.nix` | 结构化 host inventory（仓库根），也是**唯一**的 host 差异来源：`system` / `platform`（nixos / wsl / darwin）/ `form`（vm / pc / server）/ `profile`（work / personal）/ `facts`（GPU、显示器）/ `tags` / `userEnvironment` / 可选 `homeStateVersion` / 可选 `deploy`。 | `flake.nix` 按 `platform` 生成 `nixosConfigurations` / `darwinConfigurations`（wsl 归入 NixOS），按 `deploy.enable` 生成 deploy-rs nodes；`tags` 与三条轴由 `specialArgs.host` 送达每个模块 |
| `hosts/<hostname>/home.nix` | Machine File：只放机器专属的 user 级覆盖（字体大小、单机包）。 | 是否存在由 inventory 的 `userEnvironment` 声明，不由文件推断；空文件是正常状态 |
| `flake.nix` | Flake 输入/输出：formatter、`nix flake check` lint、`nix-conf` 包、扫描 `pkgs/` 得到的自定义包、`nixosConfigurations`、`darwinConfigurations`、deploy-rs 配置。 | 系统配置由 `mkSystem` / `mkDarwinSystem` 从 `inventory.nix` 注册表构建 |

---

## 辅助函数使用小结

- **`extraLibs.scanPaths`** — 用于 `modules/nixos/{common,server}/default.nix`、`programs/default.nix` 与各 `programs/<category>/default.nix`，自动扫描并导入同级模块。`server` 的扫描结果包在 `lib.optionals host.form.server` 里。
- **`lib/mkSystem.nix`** — 被 `flake.nix` 使用；负责广播（注入 `host`，无条件导入各平台树与 HM 层），门控由被导入树的 `default.nix` 承担。
- **`modules/home-manager/desktop/niri/build.nix`** — 被 `modules/home-manager/desktop/niri.nix` 使用，构建并校验 niri 配置 derivation。
- **`lib/storeLinks.nix`** — 被 `modules/home-manager/desktop/fontconfig`、`programs/gui/kitty` 使用，显式选择 in-store 或 out-of-store 软链接策略。
- **`overlays/nixpaks.nix`** — 被 `modules/nixos/desktop/nixpak.nix` 挂进 `nixpkgs.overlays`，通过 nixpak 沙盒运行 QQ 与微信。
- **`lib/nix-settings.nix`** — 被 `modules/nixos/common/nix.nix` 与 `flake.nix` 使用，统一 Nix 缓存与实验特性配置。
