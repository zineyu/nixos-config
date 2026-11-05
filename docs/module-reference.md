# Module Reference

本文件是仓库中 NixOS / Home Manager 模块与辅助函数的速查表。新增、删除或重命名模块时，请同步更新本文件。

仓库的顶层分工：

| 目录 | 职责 |
|------|------|
| `programs/` | 纯软件：每个程序一个自包含 Home Manager 模块目录（`zine.programs.<name>`） |
| `modules/` | 系统侧配置：`nixos/`、`darwin/`（按平台），`desktop/`（桌面子系统，含 `home/` 与 `system/`），`base/`（平台无关 HM 基础） |
| `home/<hostname>.nix` | 机器开关表：只设 `zine.programs.*` / `zine.services.*` |
| `hosts/<hostname>/` | 该机器的系统级模块 |

---

## NixOS System Modules

### `modules/nixos/common/`

所有 host 共享的基础系统配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入同级 `.nix` 文件。 | `extraLibs.scanPaths` |
| `docker.nix` | 启用 Docker 守护进程并开机自启（桌面与服务器共享）。 | `virtualisation.docker` |
| `i18n.nix` | 设置系统 locale 为简体中文。 | `i18n.defaultLocale = "zh_CN.UTF-8"` |
| `nix.nix` | 共享 Nix daemon 设置，并声明 `trusted-users`。 | 导入 `lib/nix-settings.nix`；允许 unfree |
| `packages.nix` | 系统级软件清单（所有 host 共享）：fish、vim、wget。 | `environment.systemPackages` |
| `ssh.nix` | 所有 NixOS host 开启 sshd，供 tailnet 成员密钥直连。 | 仅密钥登录（`PasswordAuthentication` off）；授权 zine 的 OpenPGP auth 子钥（`vars.ssh.zinePublicKey`） |
| `system.nix` | 内核选择；引导加载器由各 host 自行配置。 | `linuxPackages_latest` |
| `tailscale.nix` | 所有 NixOS host 加入 Headscale tailnet（`hs.zineyu.cn`）。 | `services.tailscale`、`openFirewall`（UDP 41641）、`tailscale0` 为 trusted interface |
| `users.nix` | 定义单用户 `zine` 及其用户组。 | `wheel`、`video`、`render`、`docker`；shell = fish |

`modules/nixos/common/packages.nix` 是系统级软件清单：只放 `programs.<name>.enable` 与 `environment.systemPackages`，配置放同目录其他模块。

### `modules/nixos/server/`

服务器 / 远程主机的系统服务（Docker 由 `common/` 提供，此处无 `docker.nix`）。

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
| `ssh.nix` | 启用 OpenSSH 并限制 root 仅密钥登录。 | `services.openssh` |
| `vaultwarden.nix` | Vaultwarden 密码管理服务（pgsql 后端 + Nginx + ACME）。 | `services.vaultwarden`；`sops.secrets.vaultwarden`（ADMIN_TOKEN） |

### `modules/desktop/system/`

桌面子系统的系统级部分（NixOS 模块），由使用 Wayland 桌面的 host 显式导入（`hosts/tianxuan/configuration.nix`）。用户级部分见 `modules/desktop/home/`。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 显式导入下列模块，并引入 dank-greeter、`niri` 与 `aagl` flake 模块。 | 显式 imports（不同类型模块不混扫） |
| `audio.nix` | 启用 PipeWire 音频。 | `services.pipewire` |
| `desktop.nix` | 配置 greetd、niri、libinput 与 xdg-portal。 | `programs.niri`、`services.greetd`、`xdg.portal` |
| `graphics.nix` | NVIDIA 专有驱动设置。 | `hardware.nvidia`、modesetting、powerManagement |
| `input-method.nix` | 启用 Fcitx5 + Rime 输入法，含小鹤音形方案。 | `fcitx5-rime`、`rime-ice`、`rime-flypy/package.nix`、wayland 前端 |
| `networking.nix` | 桌面网络管理器与防火墙配置。 | `networking.networkmanager`；防火墙已关闭 |
| `nixpak.nix` | 用 nixpak 构建 `nixpaks.qq` 与 `nixpaks.wechat` overlay，供 `programs/gui/{qq,wechat}` 消费。 | `inputs.nixpak.lib.nixpak`；依赖 Home Manager 作为 NixOS 模块集成（`useGlobalPkgs`） |
| `packages.nix` | 桌面系统级软件清单：Steam、An Anime Game Launcher、KDE Connect。 | `programs.steam`、`programs.anime-game-launcher`、`programs.kdeconnect` |
| `rime-flypy/package.nix` | 小鹤音形 Rime 挂接配方（`.#rime-flypy`）。 | 与消费它的 `input-method.nix` 同目录 |
| `steam.nix` | Steam 与 gamescope 的图形支持。 | `hardware.graphics.enable32Bit`；防火墙整体禁用，未单独开放端口 |

---

## nix-darwin System Modules

### `modules/darwin/`

Darwin host 的系统级模块，由各 `hosts/<hostname>/default.nix` 显式导入。

| File | Purpose | Notable |
|------|---------|---------|
| `sops.nix` | Darwin host 的 sops-nix 基础配置（age identity rootfs 副本）。 | `/var/lib/sops-nix/key.txt` |
| `tailscale.nix` | Darwin host 的 tailnet 接入：tailscaled LaunchDaemon + 自定义 MagicDNS 域 resolver。 | `services.tailscale`、`/etc/resolver/ts.zineyu.cn` |
| `remote-login.nix` | 开启 macOS 自带 SSH（Remote Login），供 tailnet 成员直连。 | `launchctl` 操作 `com.openssh.sshd`；公钥授权经 `programs/misc/ssh` 写入 |

---

## Cross-platform System Modules

### `modules/mihomo/`

mihomo（fake-IP TUN 代理）。**一份配置、两个平台的系统级模块**：配置内容只维护 `config.yaml`，平台差异（launchd vs systemd、状态目录、凭据挂载方式）留在各自的 `.nix` 里。

| File | Purpose | Notable |
|------|---------|---------|
| `config.yaml` | 两个平台共用的 mihomo 配置（DNS、`fake-ip-filter`、规则、`proxy-providers`）。 | `path: "@proxies_file@"` 由各平台模块在构建期替换为代理凭据路径 |
| `darwin.nix` | macOS：root LaunchDaemon 跑 mihomo，代理凭据取自 sops 文件并由 `SAFE_PATHS` 授权。 | 运行时状态 `/var/lib/mihomo`；`secrets/mihomo.yaml`（sops binary） |
| `nixos.nix` | Linux：`services.mihomo`（systemd，`DynamicUser` + TUN 能力）。 | 配置与代理凭据都通过 `LoadCredential` 挂到 `/run/credentials/mihomo.service`，凭据不落全局可读路径；`SAFE_PATHS` 指向同一目录 |

两机共用同一份 `config.yaml`：`hs.zineyu.cn` 必须在 `fake-ip-filter` 内（tailscaled 控制面直连，见 ADR-0008），tailnet 流量（`100.64.0.0/10`）通过 `route-exclude-address` 绕开 TUN。

---

## Home Manager Modules

### `modules/base/` — 平台无关的 HM 基础层

由 `lib/mkSystem.nix` 通过 `home-manager.sharedModules` 接入每个用户环境，机器文件无需导入。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 基础层聚合器：导入 `common.nix`、`agent-skills`、`services`。 | 由 `lib/mkSystem.nix` 自动接入 |
| `common.nix` | Home Manager 基础状态与自启用。 | `programs.home-manager.enable`；`home.stateVersion` 由 host inventory 注入 |
| `agent-skills/` | 自动发现仓库根目录 `skills/<command>/<name>/` 并逐项安装 agent skills。 | 每个目录必须包含 `SKILL.md`；目录名即命令，`principles/`、`tools/`、`references/` 除外；目标为 `~/.agents/skills/<name>` |
| `services/` | 用户级 systemd 服务与定时任务，按 `zine.services.<name>.enable` 门控。 | 见下表 |

#### `modules/base/services/`

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入。 | `extraLibs.scanPaths` |
| `headscale-backup-pull.nix` | 每日从 `aliyun-01` 拉取 Headscale 状态快照。 | `systemd.user.services` / `timers`；走 `programs/misc/ssh` 的 alias |

### `modules/desktop/home/` — 用户级桌面层

Wayland 桌面环境与合成器配置。机器文件显式导入本层即启用；具体软件包负责声明平台支持。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入下列模块，并安装桌面环境包（xwayland-satellite、wl-clipboard、字体）。 | `home.packages` |
| `niri.nix` | 安装 niri 配置并启动 `xwayland-satellite` 用户服务。 | 使用 `lib/niri-config.nix` 校验 `config.kdl` |
| `env.nix` | Wayland/输入法会话变量与 Qt 平台主题。 | `XDG_SESSION_TYPE = wayland`、fcitx IM 变量 |
| `dank-material-shell.nix` | DankMaterialShell（DMS）shell 与 greeter 集成。 | `inputs.dms.homeModules.dank-material-shell`、`inputs.dms.homeModules.niri` |
| `fontconfig/` | 字体默认值与配置文件。 | 使用 `lib/storeLinks.nix`（in-store + out-of-store 链接） |
| `tela-icon-theme/` | Tela GTK 图标主题。 | `gtk.iconTheme` |
| `xdg-user-dirs/` | 标准 XDG 用户目录。 | `xdg.userDirs` |
| `niri/config.kdl` | niri 主配置文件，包含 `dms/*.kdl` 片段。 | 原生配置文件 |
| `DankMaterialShell/settings.nix` | 生成的 DMS settings JSON。 | `xdg.configFile` |
| `DankMaterialShell/zen.css` | 自定义 Zen Browser 主题 CSS。 | `xdg.configFile` |

### `programs/` — 纯软件

仓库根的软件树。每个目录 = 一个程序：声明 `zine.programs.<name>.enable`，并用 `lib.mkIf cfg.enable` 同时门控安装与配置。原生配置文件与可选 `package.nix` 共置。分类只按软件种类，不按平台。

各层聚合器：`programs/default.nix` 扫描分类目录，`programs/<category>/default.nix` 扫描程序目录（`extraLibs.scanPaths`）。整棵树由 `lib/mkSystem.nix` 通过 `home-manager.sharedModules` 一次性接入，机器文件只写开关。

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
| `kitty/` | Kitty 终端，含主题与自定义配置。 | 使用 `lib/storeLinks.nix`（`mkOutOfStoreDotfiles`，指向 `programs/terminal/kitty/config/`） |
| `yazi/` | 终端文件管理器，配置拆分为 settings/keymap/theme。 | `programs.yazi` |
| `zellij/` | 终端复用器，生成 KDL 设置。 | `programs.zellij`；`settings.nix` |
| `zoxide/` | 智能目录跳转。 | `programs.zoxide` |

#### `programs/dev/` — 开发工具

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `codegraph/` | 代码知识图谱 CLI（自定义配方 + 多平台 hash 更新脚本）。 | `package.nix`、`update.sh` → `.#codegraph` |
| `dbeaver/` | DBeaver 数据库客户端。 | `programs.dbeaver` |
| `devenv/` | devenv shell 集成。 | `programs.devenv` |
| `dsh/` | dsh 编码 Agent（来自 `llm-agents-nix`）。 | `inputs.llm-agents-nix` |
| `fabric/` | fabric 自定义 patterns（commit/PR/分支名生成）与 `fabric-ai` 包。 | `xdg.configFile`，单文件链接 |
| `git/` | Git 配置，含 GPG 签名与 LFS。 | `programs.git` |
| `jj/` | Jujutsu 版本控制，含 GPG 签名。 | `programs.jujutsu` |
| `jj-bond/` | Jujutsu TUI（自定义配方）。 | `package.nix` → `.#jj-bond` |
| `mise/` | mise 运行时管理器，集成 fish。 | `programs.mise` |
| `nixvim/` | Neovim 编辑器（nixvim），核心与插件配置拆分。 | `inputs.nixvim.homeModules.nixvim`；`core.nix`、`plugins/` |
| `npm/` | npm prefix 配置。 | `programs.npm` |
| `pi/` | pi 编码 Agent：扩展、prompt 模板与虚拟模型配置。prompt 模板源目录 `prompts/`，一个 `.md` 即一个 `/命令`。 | `llm-agents-nix` 的 `pi` 包 + `home.file` |
| `vscode/` | VS Code。 | `programs.vscode` |
| `zed/` | Zed 编辑器，含 GLM 模型与 vim 键位。 | `programs.zed-editor` |

只安装包的开发工具叶子模块（每目录一个开关）：`buf`、`bun`、`ccache`（仅 tianxuan，Linux-only 构建输入）、`clang`（低优先级）、`cmake`、`dart-sass`、`gcc`、`github-cli`、`gnumake`、`go`、`lazygit`、`lazyjj`、`llvm`、`maven`、`mold`、`ninja`、`pip`、`python3`、`rustup`、`stylua`、`tree-sitter`、`uv`。

#### `programs/gui/` — 图形界面应用

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `breezex-cursor/` | BreezeX 光标主题包（自定义配方）。 | `package.nix` → `.#breezex-cursor` |
| `chromium/` | Chromium。 | `programs.chromium` |
| `cursor/` | 指针主题配置（消费 `breezex-cursor`）。 | `home.pointerCursor` |
| `dbx-desktop/` | DBX Desktop（自定义配方 + FOD hash 更新脚本）。 | `package.nix`、`update.sh` → `.#dbx-desktop` |
| `dolphin/` | KDE Dolphin 安装与默认目录关联。 | `xdg.mimeApps` |
| `firefox/` | Firefox。 | `programs.firefox` |
| `qbittorrent/` | qBittorrent（GUI BitTorrent 客户端），接管磁力链接与 `.torrent` 默认打开方式。 | `home.packages`；`xdg.mimeApps`（配置由应用自身维护在 `~/.config/qBittorrent/`） |
| `qq/` | QQ（nixpak 沙盒，消费 `modules/desktop/system/nixpak.nix` 的 overlay）。 | `pkgs.nixpaks.qq` |
| `rustdesk/` | RustDesk 客户端与被控常驻服务。 | `vars.rustdesk.publicKey`；Linux 用 `rustdesk-flutter` |
| `thunderbird/` | Thunderbird。 | `programs.thunderbird` |
| `wechat/` | 微信（nixpak 沙盒）。 | `pkgs.nixpaks.wechat` |
| `zen-browser/` | Zen Browser，使用自定义 unwrapped 包与策略。 | `inputs.zen-browser.homeModules.default`；Darwin 上重签名 |

只安装包的 GUI 叶子模块：`localsend`。

#### `programs/misc/` — 其他

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `gnupg/` | GnuPG、gpg-agent 与 SSH agent，通过 sops-nix 导入私钥。 | `programs.gpg`、`services.gpg-agent`、自定义导入服务 |
| `karabiner-elements/` | Karabiner-Elements 键盘配置（Darwin）。 | 包由 Homebrew cask 安装；`xdg.configFile` |
| `rime-ice/` | Rime Ice（雾凇拼音）输入法与 Squirrel 前端（Darwin）。 | `home.file`、`home.activation`；`squirrel/package.nix` → `.#squirrel` |
| `sops/` | sops 与 age 命令行工具。 | `home.packages` |
| `ssh/` | SSH 客户端配置：sops 渲染的公网主机（如 `aliyun-01`）+ tailnet 成员别名 + 公钥授权。 | `sops.templates.ssh-hosts`、`~/.ssh/authorized_keys`（`vars.ssh.zinePublicKey`） |

只安装包的通用 CLI 叶子模块（每目录一个开关）：`bat`、`bitwarden-cli`、`btop`、`chafa`、`chezmoi`、`curl`、`eza`、`fastfetch`、`fd`、`fzf`、`hugo`、`imagemagick`、`jq`、`just`、`lnav`、`ncdu`、`nvtop`、`pandoc`、`pigz`、`resvg`、`ripgrep`、`stow`、`trash-cli`、`tree`、`unzip`、`websocat`、`zip`。

---

## Package Recipes

自定义包不再是集中目录，而是与消费它的模块共置的 `package.nix`。`flake.nix` 扫描 `programs/` 与 `modules/desktop/`，**attr 名 = 目录名**。

| Recipe | Flake attr | 消费方 |
|--------|-----------|--------|
| `programs/dev/codegraph/package.nix` | `#codegraph` | `programs/dev/codegraph/default.nix` |
| `programs/dev/jj-bond/package.nix` | `#jj-bond` | `programs/dev/jj-bond/default.nix` |
| `programs/gui/breezex-cursor/package.nix` | `#breezex-cursor` | `programs/gui/{breezex-cursor,cursor}` |
| `programs/gui/dbx-desktop/package.nix` | `#dbx-desktop` | `programs/gui/dbx-desktop/default.nix` |
| `programs/misc/rime-ice/squirrel/package.nix` | `#squirrel` | `programs/misc/rime-ice/default.nix` |
| `modules/desktop/system/rime-flypy/package.nix` | `#rime-flypy` | `modules/desktop/system/input-method.nix` |

`nix-update --flake <attr>` 依 `meta.position` 定位配方文件，移动目录无需改脚本。`codegraph` 与 `dbx-desktop` 的更新逻辑无法由 nix-update 表达，各自带 `update.sh`；`updateScript` 会被复制进 `/nix/store`，因此脚本用 git 索引按目录名定位配方，而不是靠自身路径。

---

## Library Helpers

可复用的 Nix 函数与构造器。

| File | Purpose | Consumers |
|------|---------|-----------|
| `lib/default.nix` | 暴露 `scanPaths` 辅助函数。 | 各模块的 `default.nix` |
| `lib/mkSystem.nix` | 为所有 host 构建 `nixosSystem` / `darwinSystem`，接入 home-manager 与 sops-nix，把 `modules/base` 与 `programs` 加入 `home-manager.sharedModules`，注入 `hostname` / `homeStateVersion`，并在 `home/<hostname>.nix` 存在时自动接线 `home-manager.users.zine`。 | `flake.nix` |
| `lib/niri-config.nix` | 构建并校验 niri 配置 derivation，包含 `dms/` 片段。 | `modules/desktop/home/niri.nix` |
| `lib/nix-settings.nix` | 共享 Nix substituters、trusted public keys 与 experimental features。 | `modules/nixos/common/nix.nix`、`flake.nix` |
| `lib/nixpaks-common.nix` | 通用 nixpak 沙盒策略（GPU、DBus、bubblewrap、字体、portals）。 | `lib/nixpaks-qq.nix`、`lib/nixpaks-wechat.nix` |
| `lib/nixpaks-qq.nix` | 腾讯 QQ 的 nixpak 包装器。 | `modules/desktop/system/nixpak.nix` |
| `lib/nixpaks-wechat.nix` | 微信的 nixpak 包装器。 | `modules/desktop/system/nixpak.nix` |
| `lib/scanPaths.nix` | 返回路径下所有 `.nix` 文件与子目录（排除 `default.nix`）。 | 所有 `default.nix` 模块聚合器 |
| `lib/storeLinks.nix` | 显式 in-store / out-of-store 软链接辅助函数（`mkInStore`、`mkOutOfStore`、`mkOutOfStoreDotfiles`）。 | `modules/desktop/home/fontconfig`、`programs/terminal/kitty` |

---

## Registry & Entry Points

| File | Purpose | Notable |
|------|---------|---------|
| `vars/default.nix` | 共享变量与按 host 组织的变量。 | `git.*`、`hosts.<hostname>.hardware` 等硬件参数、`rustdesk.publicKey` |
| `hosts/default.nix` | 结构化 host inventory：attr key 为 hostname，声明 `system` / `kind`（nixos 或 darwin）/ 可选 `homeStateVersion` / 可选 `deploy` 元数据。 | `flake.nix` 按 `kind` 生成 `nixosConfigurations` / `darwinConfigurations`，按 `deploy.enable` 生成 deploy-rs nodes |
| `home/<hostname>.nix` | 每台机器的开关表：导入机器专属层（如 `modules/desktop/home`），设 `zine.programs.*` / `zine.services.*`，外加少量机器专属覆盖（如字体大小、单机包）。 | 由 `lib/mkSystem.nix` 自动接入；文件不存在则该 host 无用户环境 |
| `flake.nix` | Flake 输入/输出：formatter、`nix flake check` lint、`nix-conf` 包、扫描出的 `package.nix` 包、`nixosConfigurations`、`darwinConfigurations`、deploy-rs 配置。 | 系统配置由 `mkSystem` / `mkDarwinSystem` 从 `hosts/default.nix` 注册表构建 |

---

## 辅助函数使用小结

- **`extraLibs.scanPaths`** — 用于 `modules/nixos/{common,server}/default.nix`、`modules/base/services/default.nix`、`programs/default.nix` 与各 `programs/<category>/default.nix`，自动扫描并导入同级模块。
- **`lib/mkSystem.nix`** — 被 `flake.nix` 使用；决定「哪些层对所有用户环境生效」（base + programs）。
- **`lib/niri-config.nix`** — 被 `modules/desktop/home/niri.nix` 使用，构建并校验 niri 配置 derivation。
- **`lib/storeLinks.nix`** — 被 `modules/desktop/home/fontconfig`、`programs/terminal/kitty` 使用，显式选择 in-store 或 out-of-store 软链接策略。
- **`lib/nixpaks-*.nix`** — 被 `modules/desktop/system/nixpak.nix` 使用，通过 nixpak 沙盒运行 QQ 与微信。
- **`lib/nix-settings.nix`** — 被 `modules/nixos/common/nix.nix` 与 `flake.nix` 使用，统一 Nix 缓存与实验特性配置。
