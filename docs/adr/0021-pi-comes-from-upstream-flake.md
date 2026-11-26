# ADR-0021: pi comes from the upstream flake

## Status

Accepted (supersedes the pi package source decision of the earlier ADR, which was
removed from this directory; see Context)

## Date

2026-11-21

## Context

此前的决定是仓库不再维护 agent 工作流，`programs/dev/pi/` 只装 pi 本体（那份 ADR
已随本决定删除，历史见 git 记录）。当时
本体取自 `numtide/llm-agents.nix` 的 `packages.pi`：一个第三方 flake，用
`buildNpmPackage` + `bun build --compile` 在构建期从 npm tarball 自行编译，产物
推到 `cache.numtide.com`。这带来三个问题：

1. **版本滞后且不受本仓库控制**：装的 pi 版本由第三方 flake 的更新节奏决定，
   与上游 release 不同步（示例：上游已发 1.6.0，flake 仍停在 1.5.2），而 pi 的
   扩展 API 与配置格式随小版本变化。
2. **构建依赖第三方的私有补丁**：那个配方要自己拼 worker 入口、改
   `--compile-autoload-package-json`，才能得到可用的二进制。
3. **多一个信任面**：pi 只需要一个包，却要为它保留一份第三方打包逻辑。

上游 `earendil-works/pi` 自己就在 `stable` 分支维护 flake，提供给 Nix 用户的
用法就是 `nix profile add github:earendil-works/pi/stable`；它的 `packages.pi`
（= `packages.default`）用 `importNpmLock` 从本仓库源码构建，并在
`installCheckPhase` 里跑 `pi --version` 与原生依赖加载，产物是一份 node wrapper。

## Decision

`flake.nix` 增加 `pi` input，直接消费上游 flake：

```nix
pi = {
  url = "github:earendil-works/pi/stable";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

`programs/dev/pi/default.nix` 只声明 `home.packages = [ piPackage ]`，其中
`piPackage = inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.pi`。

- 上游 `nixpkgs` follow 到本仓库钉住的 nixos-unstable 频道修订（ADR-0011），
  让 pi 的依赖与其它包的 nixpkgs 一致、可复用缓存；上游为 x86_64-darwin 额外
  声明的 `nixpkgs-darwin-x64` 原样保留（本仓库没有该平台的 host，不会被构建）。
- 版本跟随 input：`just update` / `update.yml` 的 `nix flake update` 一并升级
  pi，不再需要自定义 `update.sh` 或 `update-pkgs.yml` 里的条目。
- 本仓库不再有 `programs/dev/pi/package.nix`。

## Consequences

- 版本与上游同步，升级路径与其它 flake input 完全一致，没有自定义 hash 表要
  维护；`.#pi` 这个自定义 package attr 随之消失（需要时用
  `nix build github:earendil-works/pi/stable#pi`）。
- pi 从源码构建：一次 npm 依赖 FOD + TypeScript 构建 + node wrapper，实测冷缓存
  约 3 分钟（`nix build` 后 `installCheckPhase` 通过）。构建只在 input 变化时
  发生；`build.yml` 每天把整机闭包推到 `zineyu.cachix.org`，而该 cache 已在
  `lib/nix-settings.nix` 里作为 substituter，所以其它机器拿到的通常是构建产物
  而非重编译。
- `nix flake check`（`update.yml`）会因为 deploy 的 activation profile 而构建
  pi，CI 每轮多几分钟；仍在 60 分钟超时内，且失败会阻止 lock 提交——上游 flake
  与本仓库钉住的 nixpkgs 不兼容时会被立刻发现。
- `llm-agents-nix` input 保留，仅服务于 `programs/dev/dsh/`。

## Alternatives considered

- **自写配方，取官方 release 的预编译 tarball**（`pi-<platform>.tar.gz` +
  `autoPatchelfHook`）：构建只需解包，秒级完成，但要多维护一张 4 平台 hash 表
  与一个 `update.sh`，并复制官方安装脚本的运行时布局知识（`PI_PACKAGE_DIR`
  等）。官方 flake 已经把这些都覆盖了，故不采用；若上游 flake 长期不可用，这是
  退路。
- **继续用 `llm-agents.nix`**：见 Context。
