#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  install.sh [options]

Options:
  --prefix PATH        Install root (default: /opt/entertech/sstarburn)
  --bin-dir PATH       Public command directory (default: /usr/local/bin)
  --python PATH        Python interpreter for venv creation (default: python3)
  --sudo-group GROUP   Group granted NOPASSWD access (default: staff)
  --repo-url URL       Git remote to clone/pull (default: git@github.com:Entertech/SStarBurn.git)
  --ref NAME           Git branch/tag to install (default: main)
  --no-sudoers         Do not install sudoers drop-in
  -h, --help           Show this help

Examples:
  ./scripts/install.sh
  ./scripts/install.sh --sudo-group entertech
  ./scripts/install.sh --repo-url git@github.com:Entertech/SStarBurn.git --ref main
USAGE
}

RAW_ARGS=("$@")
RAW_ARG_COUNT=$#
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
BASH_BIN="${BASH:-/bin/bash}"

PREFIX="/opt/entertech/sstarburn"
BIN_DIR="/usr/local/bin"
PYTHON_BIN="${PYTHON_BIN:-python3}"
SUDO_GROUP="staff"
WITH_SUDOERS=1
REPO_URL="${SSBURN_REPO_URL:-git@github.com:Entertech/SStarBurn.git}"
TRACK_REF="${SSBURN_TRACK_REF:-main}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      PREFIX="${2:-}"
      shift 2
      ;;
    --bin-dir)
      BIN_DIR="${2:-}"
      shift 2
      ;;
    --python)
      PYTHON_BIN="${2:-}"
      shift 2
      ;;
    --sudo-group)
      SUDO_GROUP="${2:-}"
      shift 2
      ;;
    --repo-url)
      REPO_URL="${2:-}"
      shift 2
      ;;
    --ref)
      TRACK_REF="${2:-}"
      shift 2
      ;;
    --no-sudoers)
      WITH_SUDOERS=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[install] error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

ensure_requirements() {
  if ! command -v git >/dev/null 2>&1; then
    echo "[install] error: git not found" >&2
    exit 2
  fi
  if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    echo "[install] error: python interpreter not found: $PYTHON_BIN" >&2
    exit 2
  fi
}

run_git_as_login_user() {
  local run_as_home=""
  if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    run_as_home="$(sudo -H -u "$SUDO_USER" sh -lc 'printf %s "$HOME"')"
    sudo -H -u "$SUDO_USER" env HOME="$run_as_home" SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}" git "$@"
    return
  fi
  git "$@"
}

prepare_repo_dir() {
  local repo_dir="$1"
  mkdir -p "$PREFIX"

  if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    local sudo_group=""
    sudo_group="$(id -gn "$SUDO_USER")"
    if [[ -d "$repo_dir" ]]; then
      chown -R "$SUDO_USER:$sudo_group" "$repo_dir"
    else
      install -d -o "$SUDO_USER" -g "$sudo_group" "$repo_dir"
    fi
    return
  fi

  mkdir -p "$repo_dir"
}

refresh_repo() {
  local repo_dir="$1"

  prepare_repo_dir "$repo_dir"
  if [[ -d "$repo_dir/.git" ]]; then
    if [[ -n "$(run_git_as_login_user -C "$repo_dir" status --porcelain)" ]]; then
      echo "[install] error: managed repo is not clean: $repo_dir" >&2
      exit 2
    fi
    run_git_as_login_user -C "$repo_dir" fetch --prune origin
    run_git_as_login_user -C "$repo_dir" checkout "$TRACK_REF"
    run_git_as_login_user -C "$repo_dir" pull --ff-only origin "$TRACK_REF"
  else
    rm -rf "$repo_dir"
    prepare_repo_dir "$repo_dir"
    run_git_as_login_user clone --branch "$TRACK_REF" --single-branch "$REPO_URL" "$repo_dir"
  fi
}

if [[ "$EUID" -ne 0 ]]; then
  if [[ -z "$SCRIPT_PATH" || ! -r "$SCRIPT_PATH" ]]; then
    echo "[install] error: re-exec requires a readable script file; download install.sh to a local path before running it." >&2
    exit 2
  fi
  REEXEC_ARGS=()
  REEXEC_ARG_COUNT=0
  if [[ "$RAW_ARG_COUNT" -gt 0 ]]; then
    REEXEC_ARGS+=("${RAW_ARGS[@]}")
    REEXEC_ARG_COUNT=${#REEXEC_ARGS[@]}
  fi
  if [[ "$REEXEC_ARG_COUNT" -gt 0 ]]; then
    exec sudo -H env PYTHON_BIN="$PYTHON_BIN" SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}" SSBURN_REPO_URL="$REPO_URL" SSBURN_TRACK_REF="$TRACK_REF" "$BASH_BIN" "$SCRIPT_PATH" "${REEXEC_ARGS[@]}"
  fi
  exec sudo -H env PYTHON_BIN="$PYTHON_BIN" SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}" SSBURN_REPO_URL="$REPO_URL" SSBURN_TRACK_REF="$TRACK_REF" "$BASH_BIN" "$SCRIPT_PATH"
fi

ensure_requirements

REPO_DIR="$PREFIX/repo"
refresh_repo "$REPO_DIR"

MANAGE_CMD="$REPO_DIR/scripts/system-manage.sh"
if [[ ! -x "$MANAGE_CMD" ]]; then
  chmod 0755 "$MANAGE_CMD"
fi

CMD=("$MANAGE_CMD" install --prefix "$PREFIX" --bin-dir "$BIN_DIR" --python "$PYTHON_BIN" --sudo-group "$SUDO_GROUP")
if [[ "$WITH_SUDOERS" -eq 0 ]]; then
  CMD+=(--no-sudoers)
fi

echo "[install] executing: ${CMD[*]}"
exec "${CMD[@]}"
