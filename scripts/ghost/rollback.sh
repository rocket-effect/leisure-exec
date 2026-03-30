#!/usr/bin/env bash
# scripts/ghost/rollback.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

cd "$DIR"

echo "[ghost] Stopping containers..."
docker compose --env-file "${ENV_FILE}" down
echo "[ghost] Rolled back."
