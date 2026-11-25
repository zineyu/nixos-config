# 自定义包配方回到 `pkgs/`

## Status

Accepted（取代 ADR-0010 的「Package recipes live next to their consumers」与
ADR-0017 Decision 第 1 条中的扫描根；ADR-0009/0010/0014/0016 关于 `programs/`
布局、广播-门控与「程序自己声明前提」的决定继续有效）

## Date

2026-11-25

## Context

ADR-0010 决定把包配方放进消费它的模块目录（`programs/<category>/<name>/package.nix`，
系统模块的放模块目录），并删除 `pkgs/`。实际用下来，共置带来三个问题：

1. **扫描根被迫分裂。** 配方不再是一类东西，而是跟着"谁消费它"散在三棵不同的树里，
   `flake.nix` 必须同时扫描 `./programs`（五个分类目录）与 `./modules/nixos/desktop`
   才能找全 7 个配方。加一个配方要猜它属于哪棵树。
2. **定位配方要经过一层无关信息。** 更新机制（`nix-update --flake <attr>`、
   `meta.position`、`git ls-files '*<name>/package.nix'`）都按目录名定位；配方与模块
   混在一棵按软件分类的树里之后，"这个包在哪"必须先回答"哪个程序消费它"。
   名字也很容易读错：`programs/misc/rime-ice/squirrel/package.nix` 里
   `rime-ice` 是程序、`squirrel` 是包，两者毫无从属关系。
3. **系统模块的配方落在 `modules/` 里。** `rime-flypy` 的配方只有一个消费方
   （`modules/nixos/desktop/input-method.nix`），结果 `modules/nixos/desktop/` 下多出
   一个只装 `package.nix` 的目录，与"`modules/` 只放系统配置"的边界冲突。

但也有一个真实例外：`programs/dev/pi/extensions/pi-fff/package.nix` 构建的
**就是它自己所在的目录**（`src = ./.`，npm 源码树带 `package-lock.json`），并且
`programs/dev/pi/default.nix` 还要按目录名把这份源码链接进 `~/.pi/agent/extensions`。

## Decision

1. **配方集中到仓库根 `pkgs/<name>/`**：`package.nix`，旁边可以放自维护的
   `update.sh`；**attr 名 = 目录名**，与 `nix-update --flake <name>` 同名。
2. **`flake.nix` 的扫描根改为 `./pkgs`**，外加 `./programs/dev/pi/extensions`
   （只为 `pi-fff`）。两条根都是显式写出的，不做全仓库递归。
3. **消费方按路径 `callPackage`**：`pkgs.callPackage ../../../pkgs/<name>/package.nix { }`。
   `programs/<category>/<name>/` 只剩 `default.nix` 与原生配置文件。
4. **`programs/` 与 `modules/` 的职责不变**：前者是"软件 + 它的配置"，后者只放系统
   配置；`pkgs/` 是"配方"，不承载任何安装或门控逻辑。
5. **例外写进规则**：配方构建的源码树就是它自己所在目录时（`src = ./.`），配方跟着
   源码走。当前只有 `pi-fff`。

## Alternatives Considered

### 保持共置（ADR-0010 的原决定）

- Pros：改一个程序时配方就在手边；不需要额外目录。
- Cons：Context 的三条全部仍在，且扫描根会随新的消费位置继续增长。
- Rejected：配方是一类有统一契约的东西（`callPackage { }`、attr = 目录名、
  `passthru.updateScript`），把它们放在一条路径下比按消费方摊开更可预测。

### 连 `pi-fff` 一起搬进 `pkgs/pi-fff/`

- Pros：`pkgs/` 覆盖全部 7 个配方，规则没有例外。
- Cons：只是把 `src = ./.` 改写成一条指回 `programs/dev/pi/extensions/pi-fff` 的相对
  路径，源码树与配方被拆到两棵树里，Scanner 与读者都要多跳一次；源码目录仍是
  `pi/default.nix` 的链接源，搬动配方不能让它少一处。
- Rejected：例外只有一处，且它的判据（"配方构建的是自己"）可以一句话写清。

### 在 `flake.nix` 里手写每个包的 `callPackage`

- Pros：显式，不需要扫描。
- Cons：ADR-0010 已经否决过（新增一个包要改三处），而且 attr 名与目录名的一致约定
  会退化。
- Rejected：目录名约定 + 两条扫描根更省事。

## Consequences

- 新增自定义包：写 `pkgs/<name>/package.nix`，flake 自动暴露 `.#<name>`，消费它的模块
  `callPackage` 那条路径。配方需要自维护更新逻辑时，`update.sh` 与配方同目录。
- 新增程序：不变（`programs/<category>/<name>/default.nix`，可选原生配置文件）。
- 更新流程不变：`nix-update` 依 `meta.position` 定位配方（目录移动无需改脚本），
  `git ls-files '*<name>/package.nix'` 仍然唯一；`lib/mkUpdateScript.nix` 生成的
  `updateScript` 从 `pkgs/<name>/` 引 `../../lib/mkUpdateScript.nix`。
- 文档同步：`README.md`、`AGENTS.md`、`GLOSSARY.md`、`docs/module-reference.md`。
