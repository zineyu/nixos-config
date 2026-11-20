# ADR-0019: Host axes are platform, form and profile

## Status

Accepted (refines ADR-0018; supersedes its "不做 profile" note)

## Date

2026-12-01

## Context

ADR-0018 把主机差异压到三条轴：事实、缺席、程度。实际使用中又暴露出三个被
混在一起的概念：

1. **构建路径与平台**：`kind` 既决定 `nixosSystem` / `darwinSystem`，又承担
   "这是哪台机器"的语义；WSL 只能藏在 `facts.form = "wsl"` 里。
2. **机器形态**：`facts.form` 同时表示 `desktop` / `laptop` / `server` / `wsl`，
   把平台（WSL）和形态（桌面机 / 笔记本）挤进了同一个枚举。
3. **使用场景**：`work` / `personal` 被塞进 `tags`，和 `docker` / `sshd` 这类
   能力选择混在一起；场景不是一个"要不要"的能力。

三者互相正交，必须各有自己的枚举与出口。

## Decision

Host Inventory 增加三条顶层轴，模块通过 `specialArgs.host` 读取同名的布尔投影：

| 轴 | 词表 | 模块写法 |
|---|---|---|
| `platform` | `nixos` / `wsl` / `darwin` | `host.platform.nixos`、`host.platform.wsl`、`host.platform.darwin` |
| `form` | `vm` / `laptop` / `pc` / `server` | `host.form.vm`、`host.form.laptop`、`host.form.pc`、`host.form.server` |
| `profile` | `work` / `personal` | `host.profile.work`、`host.profile.personal` |

每条轴投影为 `{ name = "<值>"; <每个词表值> = <bool>; }`，布尔对全词表恒存在；
`name` 是精确值，仅供审计。`platform.linux` 是便利谓词，等价于
`platform.nixos || platform.wsl`。

- `platform` 取代 `kind`：`wsl` 仍走 `nixosSystem` 构建路径，但不再伪装成
  `form` 或 `is` 谓词。
- `form` 从 `facts` 移到顶层；`vm` 为将来虚机保留，现有 `desktop` 值改为 `pc`。
- `profile` 是场景，不是能力：`tags` 只保留 `chosen` 能力（`gui` / `docker` /
  `sshd` / `tailscale` / `mihomo` / `remote-login` / `headscale-backup`）。
- `gates` 只保留 `chosen` 与 `nvidia`（由 `facts.gpu.vendors` 派生）。
  `desktop` / `server` / `wsl` 派生 gate 删除：模块直接写 `host.form.pc`、
  `host.form.server`、`host.platform.wsl`。
- `facts` 只保留硬件事实：`gpu` 与 `displays`。

## Consequences

- 模块不再比较字符串：拼错 `host.form.pcc` 在求值期报 attribute missing。
- 平台、形态、场景可以自由组合：WSL 笔记本（`platform.wsl` + `form.laptop`）、
  work 场景的 Darwin 机器（`platform.darwin` + `profile.work`）都是合法状态。
- `zine.host` 审计视图包含 `platform` / `form` / `profile`，可 `nix eval` 检查。
- `checks.zine-difference-axes` 校验三条轴的投影与 inventory 一致；
  `scripts/lint-structure.py` R5 要求每个 host 写明 `platform` / `form` / `profile`。
- 新增轴值时只改 `lib/host-axes.nix`；新增能力仍只改 `lib/host-tags.nix`。

## Alternatives considered

- **保留 `kind` / `is` / 派生 gate 作为兼容层**：会产生第二套真相，且旧名
  与新轴可以漂移；ADR-0018 的"不为中间态做兼容"原则排除。
- **把 `form` 留在 `facts`**：会让 `facts.form` 与 `host.form` 两份并存，
  且 `facts` 的必填规则与"三条轴"的校验规则混杂。
- **把 `work` / `personal` 留作 Tag**：场景无法表达"同一能力在两种场景下的
  差异"，且 `tags` 的闭集是能力词表，不应收场景。
