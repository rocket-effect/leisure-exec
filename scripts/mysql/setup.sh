#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[mysql] Starting MySQL standalone server..."

if ! command -v docker &>/dev/null; then
  echo "[mysql] ERROR: docker is not installed or not in PATH" >&2
  exit 1
fi

docker compose --env-file ../../.env up -d --pull always

echo "[mysql] MySQL is up."
echo "[mysql] Host port : $(grep '^MYSQL_PORT=' ../../.env | cut -d= -f2 | cut -d: -f1)"
echo "[mysql] Root pass : $(grep '^MYSQL_ROOT_PASSWORD=' ../../.env | cut -d= -f2)"
echo "[mysql] App user  : $(grep '^MYSQL_USER=' ../../.env | cut -d= -f2)"
echo "[mysql] Connect   : mysql -h 127.0.0.1 -P $(grep '^MYSQL_PORT=' ../../.env | cut -d= -f2 | cut -d: -f1) -u root -p"
