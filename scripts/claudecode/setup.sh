#!/usr/bin/env bash
# scripts/claudecode/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

echo "[claudecode] Checking Docker..."
if ! docker info &>/dev/null; then
  echo "[claudecode] ERROR: Docker is not running." >&2
  exit 1
fi

echo "[claudecode] Pulling image and starting container..."
docker compose --env-file "${ENV_FILE}" up -d --pull always

echo "[claudecode] Done."
echo "[claudecode] App  : http://localhost:3033"
echo "[claudecode] Vite : http://localhost:5173"

# ── Resolve paths ──────────────────────────────────────────────────────────────
