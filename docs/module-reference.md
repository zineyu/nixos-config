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
| `system.nix` | 内核、最小系统包（引导加载器由各 host 自行配置）。 | `linuxPackages_latest`、fish、vim、wget |
| `users.nix` | 定义单用户 `zine` 及其用户组。 | `wheel`、`video`、`render`、`docker`；shell = fish |
| `wireguard.nix` | 为所有注册 host 和外部客户端建立中心辐射式 WireGuard 虚拟局域网，并校验完整元数据。 | `wg0`、`10.77.0.0/24`、SOPS 私钥、固定主机名映射、hub IPv4 forwarding |

### `modules/nixos/desktop/`

桌面环境相关的系统服务与硬件配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入桌面模块，并引入 dank-greeter、`niri` 与 `aagl` flake 模块。 | `inputs.dank-greeter.nixosModules.default`、`inputs.niri.nixosModules.niri`、`inputs.aagl.nixosModules.default` |
| `an-anime-game-launcher.nix` | 安装 An Anime Game Launcher（AAGL）。 | `programs.anime-game-launcher`；按上游默认屏蔽米哈游遥测 |
| `audio.nix` | 启用 PipeWire 音频。 | `services.pipewire` |
| `desktop.nix` | 配置 greetd、niri、libinput 与 xdg-portal。 | `programs.niri`、`services.greetd`、`xdg.portal` |
| `graphics.nix` | NVIDIA 专有驱动设置。 | `hardware.nvidia`、modesetting、powerManagement |
| `input-method.nix` | 启用 Fcitx5 + Rime 输入法。 | `fcitx5-rime`、`rime-ice`、wayland 前端 |
| `kdeconnect.nix` | 启用 KDE Connect 设备互联。 | `programs.kdeconnect` |
| `networking.nix` | 桌面网络管理器与防火墙配置。 | `networking.networkmanager`；防火墙已关闭 |
| `nixpak.nix` | 用 nixpak 构建 `nixpaks.qq` 与 `nixpaks.wechat` overlay。 | `inputs.nixpak.lib.nixpak` |
| `steam.nix` | 启用 Steam、gamescope 与 32 位图形驱动。 | `programs.steam`、`hardware.graphics.enable32Bit`；防火墙整体禁用，未单独开放端口 |

### `modules/nixos/server/`

服务器 / 远程主机的系统服务（Docker 由 `common/` 提供，此处无 `docker.nix`）。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 通过 `scanPaths` 自动导入同级 `.nix` 文件。 | `extraLibs.scanPaths` |
| `fail2ban.nix` | 启用 fail2ban 入侵防护。 | `services.fail2ban` |
| `luogo_checkin.nix` | 自定义 NixOS 模块与 systemd timer，用于 Luogu 每日签到。 | 从 GitHub 构建 Go 包；`systemd.services.luogo_checkin` |
| `networking.nix` | 服务器防火墙，允许 SSH 与 HTTP/HTTPS 端口。 | `allowedTCPPorts = [ 22 80 443 ]` |
| `postgresql.nix` | 独立管理的 PostgreSQL 17 实例，供本机服务复用。 | `services.postgresql`；仅 unix socket；大版本升级需手动迁移 |
| `ssh.nix` | 启用 OpenSSH 并限制 root 仅密钥登录。 | `services.openssh` |
| `vaultwarden.nix` | Vaultwarden 密码管理服务（pgsql 后端 + Nginx + ACME）。 | `services.vaultwarden`；`sops.secrets.vaultwarden`（ADMIN_TOKEN） |

---

## Home Manager Modules

### `home/` — 机器组织文件

`home/` 只保留机器组织文件与通用入口（`<hostname>.nix`、`common.nix`、`ssh.nix`）；共享定义层（`packages/`、`shell/`、`desktop/`、`programs/`）位于 `modules/home/`，只定义、不默认启用。每台机器的组织文件 `home/<hostname>.nix` 显式导入所需定义层与裸包捆绑，并通过 `zine.programs.<name>.enable` 逐个启用软件（见 ADR-0007）。

| File | Purpose | Notable |
|------|---------|---------|
| `<hostname>.nix` | 每台机器的 Home Manager 组织文件（全显式 imports + 启用列表）。 | `lib/mkSystem.nix` 在文件存在时自动接入 `home-manager.users.zine` |
| `common.nix` | Home Manager 基础状态与自启用。 | `programs.home-manager.enable`；`home.stateVersion` 由 host inventory 注入 |
| `ssh.nix` | 基于 sops-nix 的 SSH alias 配置（如 `aliyun-01`）。 | `sops.secrets.aliyun-01`、`sops.templates.ssh-hosts` |

### `modules/home/` — 共享定义层

| File | Purpose | Notable |
|------|---------|---------|
| `packages/` | options 定义层（安装侧）与裸包捆绑。 | `zine.programs.<name>.enable` 默认 false；配置统一放 `programs/`、`desktop/` 等 |
| `shell/` | fish、bash、starship 配置。 | 原生 `fish/` 配置树共置 |
| `desktop/` | 用户级桌面环境组件（niri、DMS、字体、图标等）。 | 由需要的机器组织文件显式导入；具体包声明平台支持 |
| `programs/` | 每个用户程序一个配置模块，按 dev/terminal/gui/misc 分类。 | 各层 `default.nix` 通过 `extraLibs.scanPaths` 自动扫描 |

### `modules/home/packages/`

安装侧：声明 `zine.programs.*` options 并门控安装；无配置的裸包放 opt-in 捆绑。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 聚合基础 options 类别（shell、dev、terminal、misc）。 | 机器文件经 `../modules/home/packages` 一次性获得基础 option 声明 |
| `shell.nix` | fish、bash、starship 开关。 | `zine.programs.{fish,bash,starship}` |
| `dev.nix` | 有配置的开发程序开关。 | git、jujutsu、mise、devenv、npm、vscode、dbeaver、nixvim、zed-editor、fabric |
| `terminal.nix` | 终端程序开关。 | kitty、atuin、yazi、zellij、zoxide |
| `misc.nix` | 其他工具开关。 | aria2、gpg、ssh、sops（age+sops 包） |
| `gui.nix` | GUI 程序开关。 | firefox、chromium、thunderbird、dbx-desktop、zen-browser、dolphin |
| `tools.nix` | CLI 裸包捆绑（opt-in）。 | bat、ripgrep、fzf、eza、nvtop 等 |
| `dev-tools.nix` | 开发工具链与编码 Agent 裸包捆绑（opt-in）。 | clang、go、rustup、codex、pi、自定义 `pkgs/` 包 |
| `gui-extras.nix` | GUI 裸包捆绑（opt-in）。 | localsend、nixpaks.qq/wechat、orca、easycli、breezex-cursor |
| `desktop.nix` | 桌面环境包捆绑（opt-in）。 | DankMaterialShell、字体、xwayland-satellite、wl-clipboard |

### `modules/home/shell/`

Shell 配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入 fish、bash 与 starship 模块。 | — |
| `fish.nix` | Fish shell，包含别名、vi 键位、fzf 与 devenv 集成。 | `programs.fish`；链接原生 `fish/` 配置树 |
| `bash.nix` | 最小化 Bash 配置。 | `programs.bash`、基础别名 |
| `starship.nix` | Starship 提示符，含自定义 jj 与 git 模块。 | `programs.starship` |

### `modules/home/desktop/`

桌面环境与 Wayland 合成器配置；由机器组织文件显式选择，具体依赖的平台支持由包定义决定。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 显式导入 niri、DankMaterialShell、桌面环境变量与下表中的非程序项。 | — |
| `niri.nix` | 安装 niri 配置并启动 `xwayland-satellite` 用户服务。 | 使用 `lib/niri-config.nix` 校验 `config.kdl` |
| `env.nix` | Wayland/输入法会话变量与 Qt 平台主题。 | `XDG_SESSION_TYPE = wayland`、fcitx IM 变量 |
| `dank-material-shell.nix` | DankMaterialShell（DMS）shell 与 greeter 集成。 | `inputs.dms.homeModules.dank-material-shell`、`inputs.dms.homeModules.niri` |
| `fontconfig/` | 字体默认值与配置文件。 | 使用 `lib/storeLinks.nix`（in-store + out-of-store 链接） |
| `tela-icon-theme/` | Tela GTK 图标主题。 | `gtk.iconTheme` |
| `xdg-user-dirs/` | 标准 XDG 用户目录。 | `xdg.userDirs` |
| `niri/config.kdl` | niri 主配置文件，包含 `dms/*.kdl` 片段。 | 原生配置文件 |
| `DankMaterialShell/settings.nix` | 生成的 DMS settings JSON。 | `xdg.configFile` |
| `DankMaterialShell/zen.css` | 自定义 Zen Browser 主题 CSS。 | `xdg.configFile` |

### `modules/home/programs/`

每个应用一个 Home Manager 配置模块，按用途分为 4 个类别目录；各层 `default.nix` 通过 `extraLibs.scanPaths` 自动扫描导入，新增模块无需注册。模块只放配置；安装与启用开关见 `modules/home/packages/`。

#### `programs/dev/` — 开发工具链

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `devenv/` | devenv shell 集成。 | `programs.devenv` |
| `fabric/` | fabric 自定义 patterns（commit/PR/分支名生成）。 | `xdg.configFile`，单文件链接 |
| `git/` | Git 配置，含 GPG 签名与 LFS。 | `programs.git` |
| `jj/` | Jujutsu 版本控制，含 GPG 签名。 | `programs.jujutsu` |
| `mise/` | mise 运行时管理器，集成 fish。 | `programs.mise` |
| `nixvim/` | Neovim 编辑器（nixvim），核心与插件配置拆分。 | `inputs.nixvim.homeModules.nixvim`；`core.nix`、`plugins/` |
| `npm/` | npm prefix 配置。 | `programs.npm` |
| `zed/` | Zed 编辑器，含 GLM 模型与 vim 键位。 | `programs.zed-editor` |

#### `programs/terminal/` — 终端与 shell 增强

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `atuin/` | Shell 历史同步，集成 fish。 | `programs.atuin` |
| `kitty/` | Kitty 终端，含主题与自定义配置。 | 使用 `lib/storeLinks.nix`（`mkOutOfStoreDotfiles`） |
| `yazi/` | 终端文件管理器，配置拆分为 settings/keymap/theme。 | `programs.yazi`；`settings.nix`、`keymap.nix`、`theme.nix` |
| `zellij/` | 终端复用器，生成 KDL 设置。 | `programs.zellij`；`settings.nix` |
| `zoxide/` | 智能目录跳转。 | `programs.zoxide` |

#### `programs/gui/` — 图形界面应用

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `cursor/` | BreezeX 光标主题与指针配置。 | 自定义 `pkgs/breezex-cursor.nix` derivation |
| `dolphin/` | KDE Dolphin 默认目录关联。 | `xdg.mimeApps` |
| `zen-browser/` | Zen Browser，使用自定义 unwrapped 包与策略。 | `inputs.zen-browser.homeModules.default` |

#### `programs/misc/` — 其他

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `aria2/` | 下载管理器，启用 RPC。 | `programs.aria2` |
| `gnupg/` | GnuPG、gpg-agent 与 SSH agent，通过 sops-nix 导入私钥。 | `programs.gpg`、`services.gpg-agent`、自定义导入服务 |
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
| `lib/nixpaks-qq.nix` | 腾讯 QQ 的 nixpak 包装器。 | `modules/home/packages/gui-extras.nix` |
| `lib/nixpaks-wechat.nix` | 微信的 nixpak 包装器。 | `modules/home/packages/gui-extras.nix` |
| `lib/scanPaths.nix` | 返回路径下所有 `.nix` 文件与子目录（排除 `default.nix`）。 | 所有 `default.nix` 模块聚合器 |
| `lib/storeLinks.nix` | 显式 in-store / out-of-store 软链接辅助函数（`mkInStore`、`mkOutOfStore`、`mkOutOfStoreDotfiles`）。 | `fontconfig`、`kitty` |
---

## Registry & Entry Points

| File | Purpose | Notable |
|------|---------|---------|
| `vars/default.nix` | 共享变量与按 host 组织的变量。 | `git.*`、WireGuard overlay/外部 peer 设置、`hosts.<hostname>.wireguard.*`、硬件参数 |
| `hosts/default.nix` | 结构化 host inventory：attr key 为 hostname，声明 `system` / `kind`（nixos 或 darwin）/ 可选 `homeStateVersion` / 可选 `deploy` 元数据。 | `flake.nix` 按 `kind` 生成 `nixosConfigurations` / `darwinConfigurations`，按 `deploy.enable` 生成 deploy-rs nodes |
| `flake.nix` | Flake 输入/输出：formatter、`nix flake check` lint、`nix-conf` 包、`nixosConfigurations`、`darwinConfigurations`、deploy-rs 配置。 | 系统配置由 `mkSystem` / `mkDarwinSystem` 从 `hosts/default.nix` 注册表构建 |

---

## 辅助函数使用小结

- **`extraLibs.scanPaths`** — 用于 `modules/nixos/{common,desktop,server}/default.nix`、`modules/home/programs/default.nix` 与各 `modules/home/programs/<category>/default.nix`，自动扫描并导入同级模块。
- **`lib/niri-config.nix`** — 被 `modules/home/desktop/niri.nix` 使用，构建并校验 niri 配置 derivation。
- **`lib/storeLinks.nix`** — 被 `modules/home/desktop/fontconfig`、`modules/home/programs/terminal/kitty` 使用，显式选择 in-store 或 out-of-store 软链接策略。
- **`lib/nixpaks-*.nix`** — 被 `modules/home/packages/gui-extras.nix` 使用，通过 nixpak 沙盒运行 QQ 与微信。
- **`lib/nix-settings.nix`** — 被 `modules/nixos/common/nix.nix` 与 `flake.nix` 使用，统一 Nix 缓存与实验特性配置。
