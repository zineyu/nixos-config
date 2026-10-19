#!/usr/bin/env bash
# 更新 pkgs/dbx-desktop.nix 到上游（t8y2/dbx）最新 release。
#
# hash 修复模式参考上游 .github/workflows/update-nix-pnpm-hash.yml：
#   将 FOD hash 置为 fake → nix build → 从日志解析 "got:" → 写回。
# 之所以不能直接 `nix build` 判断：FOD 的输出路径只由声明的 hash 决定（与 src
# 无关），旧 hash 的输出只要在 store / cache 里就能让构建假性通过；必须先用
# fake hash 破坏缓存键，才会真正重新抓取并暴露新 hash。
# 本脚本处理的 hash：darwin 预编译 .app、linux src、pnpmDeps、
# cargoLock.outputHashes（上游 bump Cargo.lock git 依赖时逐条修复）。
# 版本未变时也会校验构建：nixpkgs 升级 pnpm/sqlite 会让 pnpmDeps hash 失效，
# 这种情况下「无新版本 → 跳过」会让 build.yml 一直失败，故自动重建 hash。
# 通过 dbx-desktop 的 passthru.updateScript 调用：`nix run .#dbx-desktop.updateScript`
# 需在仓库检出内运行（依赖 git 定位仓库根，要求 cwd 为 flake 根目录）。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
FILE="$REPO_ROOT/pkgs/dbx-desktop.nix"
FLAKE_ROOT="$REPO_ROOT"
REPO="t8y2/dbx"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# 用 fake hash 强制重建 FOD，从失败日志解析 got: 并写回 FILE。
# 参数：flake attr 路径、该 hash 在 FILE 中的定位正则（匹配到 `hash = "` 之前）。
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

# cargoLock.outputHashes：上游 bump Cargo.lock 中的 git 依赖时，
# cargoDeps FOD 会对每条 checkout 报 hash mismatch（drv 名即 outputHashes 键），逐条修复
fix_cargo_hashes() {
  local log key got
  for _ in $(seq 1 10); do
    log=$(mktemp)
    if nix build "$FLAKE_ROOT#dbx-desktop.cargoDeps" --no-link --print-build-logs >"$log" 2>&1; then
      rm -f "$log"
      return 0
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
}

# 重建全部 FOD hash（幂等：hash 已正确时写回原值）。
repair_fods() {
  fix_fod_hash "dbx-desktop.src" 'rev = "[0-9a-f]{40}";\s*'
  fix_fod_hash "dbx-desktop.pnpmDeps" 'fetcherVersion = 4;\s*'
  fix_cargo_hashes
}

# 文件中有两处 version（darwin / linux 分支），linux 分支的为准（行尾出现更晚）
current=$(sed -n 's/^    version = "\(.*\)";$/\1/p' "$FILE" | tail -1)
latest=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$latest" || "$latest" == "null" ]]; then
  echo "error: 无法获取 $REPO 的最新 release" >&2
  exit 1
fi

if [[ "$current" == "$latest" ]]; then
  echo "dbx-desktop 已是最新 ($current)，校验构建"
  log=$(mktemp)
  if nix build "$FLAKE_ROOT#dbx-desktop" --no-link --print-build-logs >"$log" 2>&1; then
    rm -f "$log"
    echo "构建验证通过，跳过更新"
    exit 0
  fi
  echo "构建失败，重建 FOD hash（nixpkgs 升级 pnpm/sqlite 后旧 hash 会失效）"
  before=$(sha256sum "$FILE" | cut -d' ' -f1)
  repair_fods
  after=$(sha256sum "$FILE" | cut -d' ' -f1)
  if [[ "$before" == "$after" ]]; then
    echo "error: FOD hash 重建后无变化，构建失败原因不在 hash，需人工处理" >&2
    tail -40 "$log" >&2
    rm -f "$log"
    exit 1
  fi
  rm -f "$log"
  echo "pkgs/dbx-desktop.nix 已修复，等待构建验证"
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

# 3) 重建 linux FOD hash（src / pnpmDeps / cargoLock.outputHashes）
repair_fods

echo "dbx-desktop 已更新到 $latest"
