#!/usr/bin/env bash
# scripts/listmonk/rollback.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

cd "${DIR}"
echo "[listmonk] Stopping containers..."
docker compose --env-file "${ENV_FILE}" down
echo "[listmonk] Rolled back. Data volumes preserved."
