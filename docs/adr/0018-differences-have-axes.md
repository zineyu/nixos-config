# 差异分轴：事实用 facts，缺席用 gate，程度用 knob

## Status

Accepted (refines ADR-0014's Host Metadata and ADR-0016's capability rule)

## Date

2026-11-21

## Context

ADR-0014 把主机差异收敛成"模块读 `host.gates` 自门控"，ADR-0016 让 program 声明
自己需要的能力。两者解决了**缺席**（这台机器要不要某能力），但仓库里仍然存在
另外两类差异无处安放：

1. **事实**：`vars/hosts/tianxuan/hardware.{intelBusId,nvidiaBusId}` 是机器事实，
   却游离在 Host Inventory 之外，未类型化；`nvidia` tag 与这两条事实是同一件事的
   两次表达，于是有两种非法状态——打了 tag 却没写 bus id（求值崩），写了 bus id
   却没打 tag（**静默不启用**）。
2. **程度**：`hosts/tianxuan/home.nix` 直连 `programs.kitty.font.size = 12.0`，
   绕过模块接口伸进上游 option 路径。同类差异无处可放时会退化成
   `if host.name == "x"` 分支——不可审计、lint 不了。

对照 wimpysworld/nix-config（16 主机、广播-门控同构）可见它的解：机器事实放在
注册表里，能力与参数默认值**从事实派生**（`kmsconFontSize = 20 * primaryScale`、
`focus_cross_monitor = isMultiMonitor`、`gpu.hasCuda`），因此加一台机器不需要
新增任何覆盖；它剩下的 3 处 `host.name ==` 全部出现在缺少 per-host 覆盖位的地方。

## Decision

差异按**轴**表达，一轴一个出口，互不借用：

| 轴 | 判据 | 出口 | 强制 |
|---|---|---|---|
| 事实 | 值来自世界（形态、GPU、显示器、地址、密钥） | Inventory 的 `facts` / `vars` / sops | 必填，无默认值 |
| 缺席 | 只会说"要不要" | `tags`（chosen）或 facts 推导（derived）→ `host.gates` | 闭集，词表外即求值失败 |
| 程度 | 有默认值，只是这台想不一样 | 模块内的 `zine.*` option（knob） | 必须有 default |

派生规则：`facts.form` 派生 `desktop` / `server` / `wsl`；`"nvidia" ∈
facts.gpu.vendors` 派生 `nvidia`。**事实决定的能力不可声明，选择的能力不可推导**：
`tags` 的 enum 只收 `vocab.chosen`，写进 `desktop` 之类会被 enum 拒绝。

`tags` 退出模块可见面：`specialArgs.host` 只有 `gates`（布尔，对全词表恒存在）与
`facts`（值）。`zine.host.tags` 保留为审计视图，由 `modules/host-metadata.nix`
直接从 inventory 读取——模块看不到"来源"，只看得到推导结果。

优先级不自造，映射到 Nix 既有的格：`mkOption default` < `lib.mkDefault`（tag 派生
或预设）< 普通赋值（Machine File）< `mkForce`。身份只喂默认值，不参与覆盖链；
运行期身份（外接屏现数、电池）不进配置函数，走 udev / logind / niri dynamic。

Machine File（`hosts/<hostname>/home.nix`）成为**可选**文件，且只允许 `zine.*`
赋值：程序开关走 tag，参数走 knob。`userEnvironment = true` 不再要求该文件存在。

`imports` 保持无条件，门控写进模块体（`config = lib.mkIf host.gates.…`），这样
每台主机都会求值每个模块，拼写错误在四台机上同时暴露。无法在模块内部关闭的
第三方模块树（dank-greeter / niri / aagl）与 `scanPaths` 子树允许在入口门控，
但必须在同一文件用 `lint-allow-imports-gate:` 注释写明理由。

## Consequences

- 加一台机器只写事实 + 选择；`nvidia` / `desktop` / `server` / `wsl` 不再手写。
- 非法状态消失：tag 与 facts 不一致不再可能；Machine File 无法再手装包或改上游
  option；模块无法按主机名分支。
- `host.gates` / `host.facts` 是两个正交视图，不合并：`facts` 必填无默认，
  `gates` 恒存在默 false，两套策略由两个 lint 规则表达；也只有 1 处模块需要
  facts 的**值**（NVIDIA bus id），31 处只需要布尔。
- 强制手段（`scripts/lint-structure.py`，R1–R5）是本 ADR 的机检部分：
  R1 模块禁 hostname 分支、R2 imports 不得引用 host metadata、R3 Machine File 只
  允许 `zine.*`、R4 knob 必有 default、R5 Inventory 必有 facts。
- 不做：`profile` / 场景轴（同一台机在工作与个人间切换）、TOML 注册表双解析、
  golden 快照门禁、free-string tag 词表。理由见 PR 讨论：场景轴无需求；双解析会
  产生绕过 builder 的第二条读取路径；4 主机的规模下快照的维护成本高于收益。
