# Tag 词表的唯一来源。
#
# 两个消费者：
#   -  modules/host-metadata.nix 用它作为 zine.host.tags 的 enum，使 Host Inventory
#      里的拼写错误在求值期报错；
#   -  lib/mkSystem.nix 用它派生 host.gates.<tag>，使模块门控写成 host.gates.gui
#      而不是 lib.elem "gui" host.tags。后者拼错时恒为 false、静默不生效；前者
#      拼错是 "attribute 'giu' missing"，求值期即炸。
#
# 新增 tag 只需在这里加一行。词表只收**机器的属性**：机器形态、会话能力、
# 系统能力。软件分组（"dev-base" 之类）不是能力，不得加入。
[
  # 机器形态：决定导入哪棵平台树。
  "desktop" # NixOS Wayland 桌面栈（modules/desktop/{system,home}）
  "server" # 常驻服务器（modules/nixos/server）
  "wsl" # NixOS-WSL，复用 Windows 内核

  # 会话能力：该机器有可用的图形会话。
  "gui" # 可以运行图形应用（NixOS Wayland 或 macOS Aqua）

  # 系统能力。
  "docker"
  "sshd"
  "tailscale"
  "mihomo" # fake-ip TUN 代理（跨平台，modules/mihomo）
  "nvidia" # NVIDIA Optimus / PRIME offload
  "remote-login" # macOS Remote Login（nix-darwin 无对应 option）
  "headscale-backup" # 从 aliyun-01 拉取 Headscale 状态快照（用户级 timer）
]
