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

### `modules/nixos/desktop/`

桌面环境相关的系统服务与硬件配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入桌面模块，并引入 `dms` greeter 与 `niri` flake 模块。 | `inputs.dms.nixosModules.greeter`、`inputs.niri.nixosModules.niri` |
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
| `networking.nix` | 服务器防火墙，允许 SSH 端口。 | `allowedTCPPorts = [ 22 ]` |
| `ssh.nix` | 启用 OpenSSH 并限制 root 仅密钥登录。 | `services.openssh` |

---

## Home Manager Modules

### `modules/home/`

用户级配置的 orchestrator 与共享设置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 按顺序 orchestrate home 模块：`common` → `tools` → `shell` → `desktop` → `programs` → `ssh`。 | `home.username = "zine"`、`home.homeDirectory = "/home/zine"` |
| `common.nix` | Home Manager 基础状态与自启用。 | `programs.home-manager.enable` |
| `tools.nix` | 日常通用 CLI 工具（与具体开发活动无关）。 | `fzf`、`ripgrep`、`eza`、`btop`、`just`、`wl-clipboard`；开发工具链见 `programs/devtools/` |
| `ssh.nix` | 基于 sops-nix 的 SSH alias 配置（如 `aliyun-01`）。 | `sops.secrets.aliyun-01`、`sops.templates.ssh-hosts` |

### `modules/home/shell/`

Shell 配置。

| File | Purpose | Notable |
|------|---------|---------|
| `default.nix` | 导入 fish、bash 与 starship 模块。 | — |
| `fish.nix` | Fish shell，包含别名、vi 键位、fzf 与 devenv 集成。 | `programs.fish`；链接原生 `fish/` 配置树 |
| `bash.nix` | 最小化 Bash 配置。 | `programs.bash`、基础别名 |
| `starship.nix` | Starship 提示符，含自定义 jj 与 git 模块。 | `programs.starship` |

### `modules/home/desktop/`

桌面环境与 Wayland 合成器配置。

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

每个应用一个 Home Manager 模块。

| Directory | Purpose | Notable |
|-----------|---------|---------|
| `aria2/` | 下载管理器，启用 RPC。 | `programs.aria2` |
| `atuin/` | Shell 历史同步，集成 fish。 | `programs.atuin` |
| `chromium/` | Chromium 浏览器。 | `programs.chromium` |
| `coding-agents/` | LLM agent 工具包（`pi`、`codex`、`cc-switch-cli`、`omp`、`spec-kit`）。 | `inputs.llm-agents-nix` |
| `cursor/` | BreezeX 光标主题与指针配置。 | 自定义 `breezex-cursor.nix` derivation |
| `dbeaver/` | DBeaver 数据库工具。 | `programs.dbeaver` |
| `devenv/` | devenv shell 集成。 | `programs.devenv` |
| `devtools/` | 开发工具链（语言、编译器、构建工具）；通用 CLI 见 `tools.nix`。 | `clang`、`go`、`maven`、`uv`、`github-cli` 等 |
| `dolphin/` | KDE Dolphin 文件管理器与默认目录关联。 | `xdg.mimeApps` |
| `firefox/` | Firefox 浏览器。 | `programs.firefox` |
| `git/` | Git 配置，含 GPG 签名与 LFS。 | `programs.git` |
| `gnupg/` | GnuPG、gpg-agent 与 SSH agent，通过 sops-nix 导入私钥。 | `programs.gpg`、`services.gpg-agent`、自定义导入服务 |
| `jj/` | Jujutsu 版本控制，含 GPG 签名。 | `programs.jujutsu` |
| `kitty/` | Kitty 终端，含主题与自定义配置。 | 使用 `lib/storeLinks.nix`（`mkOutOfStoreDotfiles`） |
| `localsend/` | 局域网文件传输。 | `pkgs.localsend` |
| `mise/` | mise 运行时管理器，集成 fish。 | `programs.mise` |
| `neovim/` | Neovim 编辑器，使用 out-of-store 配置软链接。 | 使用 `lib/storeLinks.nix`（`mkOutOfStoreDotfiles`） |
| `npm/` | npm prefix 配置。 | `programs.npm` |
| `python/` | Python 基础包。 | `python3`、`pip` |
| `qq/` | 腾讯 QQ，通过 nixpak 沙盒运行。 | `pkgs.nixpaks.qq`（来自 `lib/nixpaks-qq.nix`） |
| `rustup/` | Rust 工具链（via rustup）。 | `pkgs.rustup`、cargo bin 加入 PATH |
| `thunderbird/` | Thunderbird 邮件客户端。 | `programs.thunderbird` |
| `wechat/` | 微信，通过 nixpak 沙盒运行。 | `pkgs.nixpaks.wechat`（来自 `lib/nixpaks-wechat.nix`） |
| `yazi/` | 终端文件管理器，配置拆分为 settings/keymap/theme。 | `programs.yazi`；`settings.nix`、`keymap.nix`、`theme.nix` |
| `zed/` | Zed 编辑器，含 GLM 模型与 vim 键位。 | `programs.zed-editor` |
| `zellij/` | 终端复用器，生成 KDL 设置。 | `programs.zellij`；`settings.nix` |
| `zen-browser/` | Zen Browser，使用自定义 unwrapped 包与策略。 | `inputs.zen-browser.homeModules.default` |
| `zoxide/` | 智能目录跳转。 | `programs.zoxide` |

---

## Library Helpers

可复用的 Nix 函数与构造器。

| File | Purpose | Consumers |
|------|---------|-----------|
| `lib/default.nix` | 暴露 `scanPaths` 辅助函数。 | 各模块的 `default.nix` |
| `lib/mkSystem.nix` | 为所有 host 构建 `nixosSystem`，并接入 home-manager 与 sops-nix。 | `flake.nix` |
| `lib/niri-config.nix` | 构建并校验 niri 配置 derivation，包含 `dms/` 片段。 | `modules/home/desktop/niri.nix` |
| `lib/nix-settings.nix` | 共享 Nix substituters、trusted public keys 与 experimental features。 | `modules/nixos/common/nix.nix`、`flake.nix` |
| `lib/nixpaks-common.nix` | 通用 nixpak 沙盒策略（GPU、DBus、bubblewrap、字体、portals）。 | `lib/nixpaks-qq.nix`、`lib/nixpaks-wechat.nix` |
| `lib/nixpaks-qq.nix` | 腾讯 QQ 的 nixpak 包装器。 | `modules/home/programs/qq` |
| `lib/nixpaks-wechat.nix` | 微信的 nixpak 包装器。 | `modules/home/programs/wechat` |
| `lib/scanPaths.nix` | 返回路径下所有 `.nix` 文件与子目录（排除 `default.nix`）。 | 所有 `default.nix` 模块聚合器 |
| `lib/storeLinks.nix` | 显式 in-store / out-of-store 软链接辅助函数（`mkInStore`、`mkOutOfStore`、`mkOutOfStoreDotfiles`）。 | `fontconfig`、`kitty`、`neovim` |

---

## Registry & Entry Points

| File | Purpose | Notable |
|------|---------|---------|
| `vars/default.nix` | 共享变量与按 host 组织的变量。 | `git.*`、`hosts.tianxuan.hostname`、`hosts.tianxuan.hardware.*` |
| `hosts/default.nix` | host 到系统架构的注册表。 | `tianxuan = x86_64-linux`、`aliyun-01 = x86_64-linux` |
| `flake.nix` | Flake 输入/输出：formatter、`nix flake check` lint、`nix-conf` 包、`nixosConfigurations`、deploy-rs 配置。 | `nixosConfigurations` 通过 `mkSystem` 从 `hosts` 构建 |

---

## 辅助函数使用小结

- **`extraLibs.scanPaths`** — 用于 `modules/nixos/common/default.nix`、`modules/nixos/desktop/default.nix`、`modules/nixos/server/default.nix` 与 `modules/home/programs/default.nix`，自动扫描并导入同级模块。
- **`lib/niri-config.nix`** — 被 `modules/home/desktop/niri.nix` 使用，构建并校验 niri 配置 derivation。
- **`lib/storeLinks.nix`** — 被 `modules/home/desktop/fontconfig`、`modules/home/programs/kitty`、`modules/home/programs/neovim` 使用，显式选择 in-store 或 out-of-store 软链接策略。
- **`lib/nixpaks-*.nix`** — 被 `modules/home/programs/qq` 与 `modules/home/programs/wechat` 使用，通过 nixpak 沙盒运行 QQ 与微信。
- **`lib/nix-settings.nix`** — 被 `modules/nixos/common/nix.nix` 与 `flake.nix` 使用，统一 Nix 缓存与实验特性配置。
