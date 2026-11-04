#!/bin/sh
# 发布 astra-serve-host 二进制到本仓库的 GitHub Release。
# 用法：scripts/upload.sh <版本号>   （版本号不带 v 前缀，如 0.2.0）
# 前置：gh 已认证、有 astra-praxis/astra-bot 权限；本机 cargo 可构建 astra-serve。
# 网络走 HTTPS（gh credential helper），不走 SSH——公司网络 SSH 到 GitHub 常被掐。
set -eu

REPO="astra-praxis/astra-bot"
SERVE_SRC="${SERVE_SRC:-$HOME/workplace/astra-serve}"
VERSION="${1:?用法: scripts/upload.sh <版本号>}"
TAG="serve-v${VERSION}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

echo "==> 构建当前平台 ($(rustc -vV | awk '/host:/ {print $2}'))"
cargo build --release --manifest-path "$SERVE_SRC/Cargo.toml" --bin astra-serve-host
HOST_TRIPLE="$(rustc -vV | awk '/host:/ {print $2}')"
EXT=""
[ "$(uname)" = "Windows_NT" ] && EXT=".exe"
ASSET="astra-serve-host-${HOST_TRIPLE}${EXT}"
cp "$SERVE_SRC/target/release/astra-serve-host${EXT}" "$ASSET"
chmod +x "$ASSET"

echo "==> 计算 sha256"
if command -v shasum >/dev/null 2>&1; then
  SHA="$(shasum -a 256 "$ASSET" | awk '{print $1}')"
else
  SHA="$(sha256sum "$ASSET" | awk '{print $1}')"
fi

echo "==> 更新 latest.json（HTTPS clone）"
git clone --depth 1 "https://github.com/${REPO}.git" repo
python3 - "$VERSION" "$TAG" "$HOST_TRIPLE" "$SHA" "$ASSET" <<'PYEOF'
import json, sys
version, tag, triple, sha, asset = sys.argv[1:6]
p = "repo/latest.json"
d = json.load(open(p))
d["version"] = version
d["tag"] = tag
d["files"][triple] = {
    "asset": asset,
    "sha256": sha,
    "url": f"https://github.com/astra-praxis/astra-bot/releases/download/{tag}/{asset}",
}
json.dump(d, open(p, "w"), indent=2, ensure_ascii=False)
print("平台条目:", ", ".join(d["files"].keys()))
PYEOF

echo "==> 创建 Release 并上传"
cd repo
gh auth setup-git 2>/dev/null || true
git add latest.json
git commit -m "release: serve-v${VERSION} (${HOST_TRIPLE})" || echo "latest.json 无变化"
git push origin HEAD:main
gh release create "$TAG" --repo "$REPO" --title "astra-serve-host v${VERSION}" \
  --notes "下载对应平台文件后按 README 安装。sha256 见 latest.json。" \
  "../$ASSET" \
  || gh release upload "$TAG" --repo "$REPO" --clobber "../$ASSET"
echo "==> 完成: $TAG"
