# 能力词表的唯一来源（ADR-0018）。两个来源，故意分开：
#
#   chosen  —— **人的选择**：硬件看不出你想不想跑 docker，要不要图形会话。
#              写在 Host Inventory 的 tags 里。
#   derived —— **由事实推出**：形态来自 facts.form，NVIDIA 来自 facts.gpu.vendors。
#              写进 tags 是错误：host-metadata.nix 用 chosen 作 enum，写了即求值失败。
#
# 两者合并成 host.gates.<能力>，对全词表恒存在（未命中为 false）。模块门控一律写
# host.gates.gui，而不是 lib.elem "gui" host.tags —— 后者拼错时恒为 false、静默
# 不生效；前者拼错是 "attribute 'giu' missing"，求值期即炸。
#
# 词表只收**机器的属性**：机器形态、会话能力、系统能力。软件分组（"dev-base"
# 之类）不是能力，不得加入。
let
  chosen = [
    # 会话能力：该机器有可用的图形会话。
    "gui"

    # 系统能力。
    "docker"
    "sshd"
    "tailscale"
    "mihomo" # fake-ip TUN 代理（跨平台，modules/mihomo）
    "remote-login" # macOS Remote Login（nix-darwin 无对应 option）
    "headscale-backup" # 从 aliyun-01 拉取 Headscale 状态快照（用户级 timer）
  ];

  derived = [
    "desktop" # facts.form == "desktop"：NixOS Wayland 桌面栈
    "server" # facts.form == "server"：常驻服务器
    "wsl" # facts.form == "wsl"：NixOS-WSL
    "nvidia" # "nvidia" ∈ facts.gpu.vendors：Optimus / PRIME offload
  ];
in
{
  inherit chosen derived;
  all = chosen ++ derived;
}
