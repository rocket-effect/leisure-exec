#!/usr/bin/env bash
# scripts/rss-feed-builder/rollback.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"
REPO_DIR="${DIR}/repo"

if [[ ! -d "${REPO_DIR}" ]]; then
  echo "[rss-feed-builder] No repo found at ${REPO_DIR} — nothing to roll back."
  exit 0
fi

echo "[rss-feed-builder] Stopping containers..."
cd "${REPO_DIR}"
docker compose --env-file "${ENV_FILE}" down
echo "[rss-feed-builder] Rolled back."
