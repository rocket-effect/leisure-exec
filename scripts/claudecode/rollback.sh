#!/usr/bin/env bash
# scripts/claudecode/rollback.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

echo "[claudecode] Stopping and removing container..."
docker compose --env-file "${ENV_FILE}" down
echo "[claudecode] Rolled back."

