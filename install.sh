#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${SSBURN_PUBLIC_INSTALL_BASE_URL:-https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main}"
CORE_URL="${BASE_URL%/}/install-core.sh?ts=$(date +%s)"

if ! command -v curl >/dev/null 2>&1; then
  echo "[install] error: curl not found" >&2
  exit 2
fi

tmp="$(mktemp)"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

curl -fsSL "$CORE_URL" -o "$tmp"
chmod 0755 "$tmp"
exec "$tmp" "$@"
