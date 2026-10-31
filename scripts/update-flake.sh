#!/usr/bin/env bash
# 更新 flake inputs，并把 nixpkgs 钉到 nixos-unstable 的「频道修订」。
#
# 为什么不用分支尖：频道修订是 Hydra 已跑完通道测试、并把产物灌进
# cache.nixos.org 的那个 commit；`nix flake update` 默认拿到的分支尖通常比它
# 新几小时到几天，那部分派生在 CI 与本机都只能源码编译 —— 例如
# llm-agents.nix 的 codex 源码编译一次约 50 分钟（4 核）。
#
# 其余 input 仍按各自分支更新；声明了 `inputs.nixpkgs.follows = "nixpkgs"` 的
# （home-manager / nix-darwin / llm-agents.nix / nixvim 以外的多数 input）会
# 随之解析到这个修订。频道修订最多比分支尖旧一两天，因此仍需跑
# `nix flake check` / 构建来确认上游模块与它兼容。
#
# 用法：`just update`；CI 的 .github/workflows/update.yml 也调用本脚本。
# 输出：仅最后一行打印本次锁定的频道修订，供 CI 写入提交信息（其余信息走 stderr）。
set -euo pipefail
cd "$(dirname "$0")/.."

nix flake update >&2

rev=$(curl -fsSL --retry 3 --retry-delay 2 https://channels.nixos.org/nixos-unstable/git-revision)
nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$rev" >&2

echo "$rev"
