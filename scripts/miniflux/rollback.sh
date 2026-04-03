#!/usr/bin/env bash
# scripts/miniflux/rollback.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

cd "${DIR}"
echo "[miniflux] Stopping containers..."
docker compose --env-file "${ENV_FILE}" down
echo "[miniflux] Rolled back. Data volumes preserved."
