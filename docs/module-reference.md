# Module Reference

本文件是仓库中 NixOS / Home Manager 模块与辅助函数的速查表。新增、删除或重命名模块时，请同步更新本文件。

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

### `modules/nixos/desktop/`

桌面环境相关的系统服务与硬件配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入桌面模块，并引入 dank-greeter、`niri` 与 `aagl` flake 模块。 | `inputs.dank-greeter.nixosModules.default`、`inputs.niri.nixosModules.niri`、`inputs.aagl.nixosModules.default` |
| `audio.nix` | 启用 PipeWire 音频。 | `services.pipewire` |
| `desktop.nix` | 配置 greetd、niri、libinput 与 xdg-portal。 | `programs.niri`、`services.greetd`、`xdg.portal` |
| `graphics.nix` | NVIDIA 专有驱动设置。 | `hardware.nvidia`、modesetting、powerManagement |
| `input-method.nix` | 启用 Fcitx5 + Rime 输入法。 | `fcitx5-rime`、`rime-ice`、wayland 前端 |
| `networking.nix` | 桌面网络管理器与防火墙配置。 | `networking.networkmanager`；防火墙已关闭 |
| `nixpak.nix` | 用 nixpak 构建 `nixpaks.qq` 与 `nixpaks.wechat` overlay。 | `inputs.nixpak.lib.nixpak` |
| `packages.nix` | 桌面系统级软件清单：Steam、An Anime Game Launcher、KDE Connect。 | `programs.steam`、`programs.anime-game-launcher`、`programs.kdeconnect` |
| `steam.nix` | Steam 与 gamescope 的图形支持。 | `hardware.graphics.enable32Bit`；防火墙整体禁用，未单独开放端口 |

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

---

## nix-darwin System Modules

### `modules/darwin/`

Darwin host 的系统级模块，由各 `hosts/<hostname>/default.nix` 显式导入。

| File | Purpose | Notable |
|------|---------|---------|
| `sops.nix` | Darwin host 的 sops-nix 基础配置（age identity rootfs 副本）。 | `/var/lib/sops-nix/key.txt` |
| `tailscale.nix` | Darwin host 的 tailnet 接入：tailscaled LaunchDaemon + 自定义 MagicDNS 域 resolver。 | `services.tailscale`、`/etc/resolver/ts.zineyu.cn` |
| `remote-login.nix` | 开启 macOS 自带 SSH（Remote Login），供 tailnet 成员直连。 | `launchctl` 操作 `com.openssh.sshd`；公钥授权经 `modules/home/ssh` 写入 |
| `mihomo.nix` | mihomo（fake-IP TUN 代理）LaunchDaemon；原生配置与模块共置于 `mihomo/config.yaml`。 | 代理凭据来自 `secrets/mihomo.yaml`（sops binary）；运行时状态在 `/var/lib/mihomo` |

---

## Home Manager Modules

### `modules/home/` — 共享用户层

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 共享层聚合器：导入 `common.nix`、`programs`、`ssh`、`agent-skills`、`bundles`、`services`。 | 机器文件的唯一共享入口 |
| `common.nix` | Home Manager 基础状态与自启用。 | `programs.home-manager.enable`；`home.stateVersion` 由 host inventory 注入 |
| `ssh/` | SSH 客户端配置：sops 渲染的公网主机（如 `aliyun-01`）+ tailnet 成员别名 + 公钥授权。 | `zine.programs.ssh`；`sops.templates.ssh-hosts`、`~/.ssh/authorized_keys`（`vars.ssh.zinePublicKey`） |
| `agent-skills/` | 自动发现仓库根目录 `skills/<name>/` 并逐项安装 agent skills。 | 每个目录必须包含 `SKILL.md`；目标为 `~/.agents/skills/<name>` |
| `bundles/` | 无配置裸包捆绑，按 `zine.bundles.{cli,dev,gui}.enable` 门控。 | 见下表 |
| `services/` | 用户级 systemd 服务与定时任务，按 `zine.services.<name>.enable` 门控。 | 见下表 |
| `desktop/` | 用户级桌面环境层（niri、DMS、字体、图标等），由机器文件显式导入。 | 导入即启用，无独立开关 |
| `programs/` | 每个程序一个自包含目录，按 shell/terminal/dev/gui/misc 分类。 | 各层 `default.nix` 通过 `extraLibs.scanPaths` 自动扫描 |

### `modules/home/programs/`

每个目录 = 一个程序：声明 `zine.programs.<name>.enable`，并用 `lib.mkIf cfg.enable` 同时门控安装与配置。原生配置文件与模块共置。

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
| `kitty/` | Kitty 终端，含主题与自定义配置。 | 使用 `lib/storeLinks.nix`（`mkOutOfStoreDotfiles`） |
| `yazi/` | 终端文件管理器，配置拆分为 settings/keymap/theme。 | `programs.yazi` |
| `zellij/` | 终端复用器，生成 KDL 设置。 | `programs.zellij`；`settings.nix` |
| `zoxide/` | 智能目录跳转。 | `programs.zoxide` |

#### `programs/dev/` — 开发工具

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `dbeaver/` | DBeaver 数据库客户端。 | `programs.dbeaver` |
| `devenv/` | devenv shell 集成。 | `programs.devenv` |
| `fabric/` | fabric 自定义 patterns（commit/PR/分支名生成）与 `fabric-ai` 包。 | `xdg.configFile`，单文件链接 |
| `git/` | Git 配置，含 GPG 签名与 LFS。 | `programs.git` |
| `jj/` | Jujutsu 版本控制，含 GPG 签名。 | `programs.jujutsu` |
| `mise/` | mise 运行时管理器，集成 fish。 | `programs.mise` |
| `nixvim/` | Neovim 编辑器（nixvim），核心与插件配置拆分。 | `inputs.nixvim.homeModules.nixvim`；`core.nix`、`plugins/` |
| `npm/` | npm prefix 配置。 | `programs.npm` |
| `pi/` | pi 编码 Agent：扩展、workflow package 与虚拟模型配置。 | `llm-agents-nix` 的 `pi` 包 + `home.file` |
| `vscode/` | VS Code。 | `programs.vscode` |
| `zed/` | Zed 编辑器，含 GLM 模型与 vim 键位。 | `programs.zed-editor` |

#### `programs/gui/` — 图形界面应用

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `chromium/` | Chromium。 | `programs.chromium` |
| `cursor/` | BreezeX 光标主题与指针配置。 | 自定义 `pkgs/breezex-cursor.nix` derivation |
| `dbx-desktop/` | DBX Desktop。 | 自定义 `pkgs/dbx-desktop.nix` derivation |
| `dolphin/` | KDE Dolphin 安装与默认目录关联。 | `xdg.mimeApps` |
| `firefox/` | Firefox。 | `programs.firefox` |
| `qbittorrent/` | qBittorrent（GUI BitTorrent 客户端），接管磁力链接与 `.torrent` 默认打开方式。 | `home.packages`；`xdg.mimeApps`（配置由应用自身维护在 `~/.config/qBittorrent/`） |
| `thunderbird/` | Thunderbird。 | `programs.thunderbird` |
| `zen-browser/` | Zen Browser，使用自定义 unwrapped 包与策略。 | `inputs.zen-browser.homeModules.default`；Darwin 上重签名 |

#### `programs/misc/` — 其他

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `gnupg/` | GnuPG、gpg-agent 与 SSH agent，通过 sops-nix 导入私钥。 | `programs.gpg`、`services.gpg-agent`、自定义导入服务 |
| `karabiner-elements/` | Karabiner-Elements 键盘配置（Darwin）。 | 包由 Homebrew cask 安装；`xdg.configFile` |
| `rime-ice/` | Rime Ice（雾凇拼音）输入法与 Squirrel 前端（Darwin）。 | `home.file`、`home.activation` |
| `sops/` | sops 与 age 命令行工具。 | `home.packages` |

### `modules/home/bundles/`

无配置叶子包，安装由 `zine.bundles.<name>.enable` 门控。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入三个捆绑。 | — |
| `cli.nix` | 通用 CLI 工具（bat、ripgrep、fzf、eza、nvtop 等）。 | `zine.bundles.cli` |
| `dev.nix` | 语言/编译器/构建工具、开发辅助、编码 Agent 与自定义 `pkgs/` 包。 | `zine.bundles.dev`；`llm-agents-nix` |
| `gui.nix` | 无独立配置的 GUI 软件（localsend、nixpak 沙盒 QQ/微信、光标主题包）。 | `zine.bundles.gui` |

### `modules/home/services/`

用户级 systemd 服务，由 `zine.services.<name>.enable` 门控。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入。 | `extraLibs.scanPaths` |
| `headscale-backup-pull.nix` | 每日从 `aliyun-01` 拉取 Headscale 状态快照。 | `systemd.user.services` / `timers`；走 `modules/home/ssh` 的 alias |

### `modules/home/desktop/`

桌面环境与 Wayland 合成器配置。导入本层即启用；具体软件包负责声明平台支持。

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

---

## Library Helpers

可复用的 Nix 函数与构造器。

| File | Purpose | Consumers |
|------|---------|-----------|
| `lib/default.nix` | 暴露 `scanPaths` 辅助函数。 | 各模块的 `default.nix` |
| `lib/mkSystem.nix` | 为所有 host 构建 `nixosSystem` / `darwinSystem`，接入 home-manager 与 sops-nix，注入 `hostname` / `homeStateVersion`，并在 `home/<hostname>.nix` 存在时自动接线 `home-manager.users.zine`。 | `flake.nix` |
| `lib/niri-config.nix` | 构建并校验 niri 配置 derivation，包含 `dms/` 片段。 | `modules/home/desktop/niri.nix` |
| `lib/nix-settings.nix` | 共享 Nix substituters、trusted public keys 与 experimental features。 | `modules/nixos/common/nix.nix`、`flake.nix` |
| `lib/nixpaks-common.nix` | 通用 nixpak 沙盒策略（GPU、DBus、bubblewrap、字体、portals）。 | `lib/nixpaks-qq.nix`、`lib/nixpaks-wechat.nix` |
| `lib/nixpaks-qq.nix` | 腾讯 QQ 的 nixpak 包装器。 | `modules/home/bundles/gui.nix` |
| `lib/nixpaks-wechat.nix` | 微信的 nixpak 包装器。 | `modules/home/bundles/gui.nix` |
| `lib/scanPaths.nix` | 返回路径下所有 `.nix` 文件与子目录（排除 `default.nix`）。 | 所有 `default.nix` 模块聚合器 |
| `lib/storeLinks.nix` | 显式 in-store / out-of-store 软链接辅助函数（`mkInStore`、`mkOutOfStore`、`mkOutOfStoreDotfiles`）。 | `fontconfig`、`kitty` |

---

## Registry & Entry Points

| File | Purpose | Notable |
|------|---------|---------|
| `vars/default.nix` | 共享变量与按 host 组织的变量。 | `git.*`、`hosts.<hostname>.hardware` 等硬件参数 |
| `hosts/default.nix` | 结构化 host inventory：attr key 为 hostname，声明 `system` / `kind`（nixos 或 darwin）/ 可选 `homeStateVersion` / 可选 `deploy` 元数据。 | `flake.nix` 按 `kind` 生成 `nixosConfigurations` / `darwinConfigurations`，按 `deploy.enable` 生成 deploy-rs nodes |
| `home/<hostname>.nix` | 每台机器的组织文件：导入 `modules/home`（必要时加 `modules/home/desktop`），再设置开关。 | 由 `lib/mkSystem.nix` 自动接入；文件不存在则该 host 无用户环境 |
| `flake.nix` | Flake 输入/输出：formatter、`nix flake check` lint、`nix-conf` 包、`nixosConfigurations`、`darwinConfigurations`、deploy-rs 配置。 | 系统配置由 `mkSystem` / `mkDarwinSystem` 从 `hosts/default.nix` 注册表构建 |

---

## 辅助函数使用小结

- **`extraLibs.scanPaths`** — 用于 `modules/nixos/{common,desktop,server}/default.nix`、`modules/home/programs/default.nix` 与各 `modules/home/programs/<category>/default.nix`、`modules/home/services/default.nix`，自动扫描并导入同级模块。
- **`lib/niri-config.nix`** — 被 `modules/home/desktop/niri.nix` 使用，构建并校验 niri 配置 derivation。
- **`lib/storeLinks.nix`** — 被 `modules/home/desktop/fontconfig`、`modules/home/programs/terminal/kitty` 使用，显式选择 in-store 或 out-of-store 软链接策略。
- **`lib/nixpaks-*.nix`** — 被 `modules/home/bundles/gui.nix` 使用，通过 nixpak 沙盒运行 QQ 与微信。
- **`lib/nix-settings.nix`** — 被 `modules/nixos/common/nix.nix` 与 `flake.nix` 使用，统一 Nix 缓存与实验特性配置。
