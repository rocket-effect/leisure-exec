#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[postgres] Stopping PostgreSQL containers..."
docker compose --env-file ../../.env down
echo "[postgres] PostgreSQL stopped. Data volumes preserved."
