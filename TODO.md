# TODO

一次性清理项：做完即删条目。不需要长期维护的事项不写在这里。

## 等 nix-update ≥ 1.17.0，删掉 `lib/mkUpdateScript.nix` 里的 prefetch

- **为什么**：Nix 2.35 起 `nix flake metadata` 只报告 flake 源的 store 路径、不再真的复制
  （lazy trees），nix-update ≤ 1.16 因此在求值阶段就报
  `opening file "/nix/store/…-source": No such file or directory`（Mic92/nix-update#687）——
  包已经是最新版本也一样失败。当前 lock 里的 nixpkgs（nixos-unstable 频道 rev `2786a2a`，
  2026-11-21）仍带 1.16.0，所以 `breezex-cursor` / `jj-bond` / `rime-flypy` / `squirrel`
  的 updateScript 先用一行 `nix flake prefetch` 把工作树落盘兜住。
- **触发条件**：nixpkgs 里的 nix-update ≥ 1.17.0（nixpkgs commit `d164824ab9f0`，
  2026-11-22，nix-update 自己改用了 `nix flake prefetch`）。频道 rev 越过该 commit 后，
  `update.yml` 的日常 lock 更新就会把它带进来。
- **怎么确认**（输出 ≥ 1.17.0 即可动手）：

  ```bash
  nix eval --raw --impure --expr \
    '(builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux.nix-update.version'
  ```

- **怎么改**：删掉 `lib/mkUpdateScript.nix` 里 `text` 中的
  `nix flake prefetch --json . >/dev/null` 一行；helper 本身保留（它仍是这四个配方的唯一
  更新入口）。改完 `nix run .#jj-bond.updateScript` 应仍以 `Not updating version, already …`
  正常退出。
