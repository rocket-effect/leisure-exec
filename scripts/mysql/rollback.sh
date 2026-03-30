#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[mysql] Stopping MySQL containers..."
docker compose --env-file ../../.env down
echo "[mysql] MySQL stopped. Data volumes preserved."
