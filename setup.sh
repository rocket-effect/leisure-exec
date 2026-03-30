#!/usr/bin/env bash
# setup.sh — leisure-exec orchestrator
#
# Usage:
#   bash setup.sh              # runs all platforms listed in platforms.txt
#   bash setup.sh --dry-run    # print plan without executing
#   bash setup.sh --help
#
# To choose which platforms run: edit platforms.txt (one name per line).
# Each platform is a folder under scripts/ with its own setup.sh + rollback.sh.
#
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "ERROR: run with bash, not sh.  Usage: bash setup.sh" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
PLATFORMS_FILE="${ROOT_DIR}/platforms.txt"
DRY_RUN=0

# ── Args ───────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h)
      echo "Usage: bash setup.sh [--dry-run] [--help]"
      echo "Edit platforms.txt to choose which platforms to run."
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Read platforms.txt (skip blank lines and # comments) ──────────────────────
PLATFORMS=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"          # strip inline comments
  line="${line// /}"          # strip spaces
  [[ -z "$line" ]] && continue
  PLATFORMS+=("$line")
done < "$PLATFORMS_FILE"

if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
  echo "Nothing to run — platforms.txt is empty."
  exit 0
fi

TOTAL=${#PLATFORMS[@]}

echo ""
echo "======================================================"
echo "  leisure-exec setup — $(date '+%Y-%m-%d %H:%M:%S')"
echo "======================================================"
echo "  Platforms: ${PLATFORMS[*]}"
echo ""

[[ $DRY_RUN -eq 1 ]] && echo "  DRY RUN — no scripts will be executed" && echo ""

# ── Dry run ────────────────────────────────────────────────────────────────────
if [[ $DRY_RUN -eq 1 ]]; then
  idx=0
  for platform in "${PLATFORMS[@]}"; do
    (( ++idx ))
    setup="${SCRIPTS_DIR}/${platform}/setup.sh"
    rollback="${SCRIPTS_DIR}/${platform}/rollback.sh"
    compose="${SCRIPTS_DIR}/${platform}/docker-compose.yml"
    echo "  [$idx/$TOTAL] $platform"
    echo "    setup.sh        : $setup"
    echo "    rollback.sh     : $rollback"
    echo "    docker-compose  : $compose"
    [[ ! -f "$setup" ]]   && echo "    WARNING: setup.sh not found!"
    [[ ! -f "$rollback" ]] && echo "    WARNING: rollback.sh not found!"
    [[ ! -f "$compose" ]] && echo "    WARNING: docker-compose.yml not found!"
    echo ""
  done
  echo "Dry run done. Run without --dry-run to execute."
  exit 0
fi

# ── Rollback ───────────────────────────────────────────────────────────────────
COMPLETED=()

_rollback() {
  echo ""
  echo "ERROR: setup failed at '$1' — rolling back completed platforms..." >&2
  for (( i=${#COMPLETED[@]}-1; i>=0; i-- )); do
    local platform="${COMPLETED[$i]}"
    local rb="${SCRIPTS_DIR}/${platform}/rollback.sh"
    echo "  Rolling back: $platform"
    if [[ -f "$rb" ]]; then
      (cd "${SCRIPTS_DIR}/${platform}" && bash rollback.sh) || echo "  WARNING: rollback errored for $platform (continuing)"
    else
      echo "  WARNING: no rollback.sh for $platform"
    fi
  done
  echo "Rollback complete."
}

trap 'echo ""; echo "Interrupted."; _rollback "SIGINT"; exit 130' INT

# ── Run platforms ──────────────────────────────────────────────────────────────
idx=0
for platform in "${PLATFORMS[@]}"; do
  (( ++idx ))
  setup="${SCRIPTS_DIR}/${platform}/setup.sh"

  echo "------------------------------------------------------"
  echo "  [$idx/$TOTAL] $platform"
  echo "------------------------------------------------------"

  if [[ ! -f "$setup" ]]; then
    echo "ERROR: setup.sh not found: $setup" >&2
    _rollback "$platform"
    exit 1
  fi

  [[ ! -x "$setup" ]] && chmod +x "$setup"

  if ! (cd "${SCRIPTS_DIR}/${platform}" && bash setup.sh); then
    _rollback "$platform"
    exit 1
  fi

  COMPLETED+=("$platform")
done

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "======================================================"
echo "  All $TOTAL platform(s) set up successfully!"
for p in "${COMPLETED[@]}"; do
  echo "  ✓ $p"
done
echo "======================================================"
echo ""
