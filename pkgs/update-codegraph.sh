#!/usr/bin/env bash
# 更新 pkgs/codegraph.nix 的版本与 4 平台 hash 表。
# codegraph 的 src hash 是 hashes.${platform} 间接引用（多平台 hash 表），
# nix-update 无法处理，由本脚本维护。
# 通过 codegraph 的 passthru.updateScript 调用：`nix run .#codegraph.updateScript`
# 需在仓库检出内运行（依赖 git 定位仓库根，要求 cwd 为 flake 根目录）。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
FILE="$REPO_ROOT/pkgs/codegraph.nix"
REPO="colbymchenry/codegraph"
PLATFORMS=(darwin-arm64 darwin-x64 linux-arm64 linux-x64)

current=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$FILE" | head -1)
latest=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$latest" || "$latest" == "null" ]]; then
  echo "error: 无法获取 $REPO 的最新 release" >&2
  exit 1
fi

if [[ "$current" == "$latest" ]]; then
  echo "codegraph 已是最新 ($current)，跳过"
  exit 0
fi

echo "codegraph: $current -> $latest"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for platform in "${PLATFORMS[@]}"; do
  url="https://github.com/$REPO/releases/download/v${latest}/codegraph-${platform}.tar.gz"
  echo "prefetch $url"
  curl -sfL -o "$tmp" "$url"
  hash=$(nix hash file --sri "$tmp")
  sed -i "s|^    ${platform} = \"sha256-[^\"]*\";|    ${platform} = \"${hash}\";|" "$FILE"
done

sed -i "s|^  version = \"${current}\";|  version = \"${latest}\";|" "$FILE"
echo "codegraph 已更新到 $latest"
