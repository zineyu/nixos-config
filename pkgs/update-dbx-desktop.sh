#!/usr/bin/env bash
# 更新 pkgs/dbx-desktop.nix 到上游（t8y2/dbx）最新 release。
#
# hash 修复模式参考上游 .github/workflows/update-nix-pnpm-hash.yml：
#   将 FOD hash 置为 fake → nix build → 从日志解析 "got:" → 写回 → 重建验证。
# 本脚本依次处理：darwin 预编译 .app hash、linux src hash、pnpmDeps hash、
# cargoLock.outputHashes（上游 bump Cargo.lock git 依赖时逐条修复）。
# 通过 dbx-desktop 的 passthru.updateScript 调用：`nix run .#dbx-desktop.updateScript`
# 需在仓库检出内运行（依赖 git 定位仓库根，要求 cwd 为 flake 根目录）。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
FILE="$REPO_ROOT/pkgs/dbx-desktop.nix"
FLAKE_ROOT="$REPO_ROOT"
REPO="t8y2/dbx"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# 文件中有两处 version（darwin / linux 分支），linux 分支的为准（行尾出现更晚）
current=$(sed -n 's/^    version = "\(.*\)";$/\1/p' "$FILE" | tail -1)
latest=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$latest" || "$latest" == "null" ]]; then
  echo "error: 无法获取 $REPO 的最新 release" >&2
  exit 1
fi

if [[ "$current" == "$latest" ]]; then
  echo "dbx-desktop 已是最新 ($current)，跳过"
  exit 0
fi

# 解析 tag 对应的 commit（annotated tag 需用 ^{} 剥离 tag object）
rev=$(git ls-remote "https://github.com/$REPO" "refs/tags/v${latest}^{}" | cut -f1)
if [[ -z "$rev" ]]; then
  rev=$(git ls-remote "https://github.com/$REPO" "refs/tags/v${latest}" | cut -f1)
fi
if [[ -z "$rev" ]]; then
  echo "error: 无法解析 tag v${latest} 对应的 commit" >&2
  exit 1
fi

echo "dbx-desktop: $current -> $latest ($rev)"

# 1) darwin 预编译 .app：fetchurl 直接下载，prefetch 即得正确 hash，无需构建
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
echo "prefetch darwin asset DBX_${latest}_arm64.app.tar.gz"
curl -sfL -o "$tmp" "https://github.com/$REPO/releases/download/v${latest}/DBX_${latest}_arm64.app.tar.gz"
darwin_hash=$(nix hash file --sri "$tmp")
rm -f "$tmp"

# 2) 更新两处 version、darwin fetchurl hash（文件中首个 hash）、linux rev
sed -i -E "s|^    version = \"[0-9.]+\";$|    version = \"${latest}\";|g" "$FILE"
perl -0pi -e "s|hash = \"sha256-[^\"]+\"|hash = \"${darwin_hash}\"|" "$FILE"
sed -i -E "s|^      rev = \"[0-9a-f]{40}\";$|      rev = \"${rev}\";|" "$FILE"

# 3) linux FOD hash 修复：置 fake hash → 构建解析 got: → 写回
fix_fod_hash() {
  local attr="$1" anchor="$2"
  local log got
  perl -0pi -e "s|(${anchor}hash = \")sha256-[^\"]+|\${1}${FAKE_HASH}|" "$FILE"
  log=$(mktemp)
  if nix build "$FLAKE_ROOT#$attr" --no-link --print-build-logs >"$log" 2>&1; then
    echo "error: $attr 在 fake hash 下意外构建成功" >&2
    rm -f "$log"
    exit 1
  fi
  got=$(grep -oE 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' "$log" | tail -1 | grep -oE 'sha256-[A-Za-z0-9+/=]+')
  if [[ -z "$got" ]]; then
    echo "error: 无法从构建日志解析 $attr 的新 hash" >&2
    cat "$log" >&2
    rm -f "$log"
    exit 1
  fi
  rm -f "$log"
  perl -0pi -e "s|(${anchor}hash = \")${FAKE_HASH}|\${1}${got}|" "$FILE"
  echo "$attr hash -> $got"
}

fix_fod_hash "dbx-desktop.src" 'rev = "[0-9a-f]{40}";\s*'
fix_fod_hash "dbx-desktop.pnpmDeps" 'fetcherVersion = 4;\s*'

# 4) cargoLock.outputHashes：上游 bump Cargo.lock 中的 git 依赖时，
#    cargoDeps FOD 会对每条 checkout 报 hash mismatch（drv 名即 outputHashes 键），逐条修复
for _ in $(seq 1 10); do
  log=$(mktemp)
  if nix build "$FLAKE_ROOT#dbx-desktop.cargoDeps" --no-link --print-build-logs >"$log" 2>&1; then
    rm -f "$log"
    break
  fi
  key=$(grep -oE "fixed-output derivation '/nix/store/[a-z0-9]+-[^']+\.drv'" "$log" | head -1 | sed -E "s|.*-[0-9a-z]+-([^']+)\.drv'|\1|")
  got=$(grep -oE 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' "$log" | tail -1 | grep -oE 'sha256-[A-Za-z0-9+/=]+')
  if [[ -z "$key" || -z "$got" ]]; then
    echo "error: cargoDeps 构建失败且无法自动解析 outputHashes，需人工处理" >&2
    cat "$log" >&2
    rm -f "$log"
    exit 1
  fi
  rm -f "$log"
  sed -i -E "s|\"${key}\" = \"sha256-[^\"]+\";|\"${key}\" = \"${got}\";|" "$FILE"
  echo "cargoLock.outputHashes[$key] -> $got"
done

echo "dbx-desktop 已更新到 $latest"
