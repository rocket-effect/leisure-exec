#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[postgres] Starting PostgreSQL standalone server..."

if ! command -v docker &>/dev/null; then
  echo "[postgres] ERROR: docker is not installed or not in PATH" >&2
  exit 1
fi

docker compose --env-file ../../.env up -d --pull always

echo "[postgres] PostgreSQL is up."
echo "[postgres] Host port : $(grep '^POSTGRES_PORT=' ../../.env | cut -d= -f2 | cut -d: -f1)"
echo "[postgres] User      : $(grep '^POSTGRES_USER=' ../../.env | cut -d= -f2)"
echo "[postgres] Connect   : psql -h 127.0.0.1 -p $(grep '^POSTGRES_PORT=' ../../.env | cut -d= -f2 | cut -d: -f1) -U $(grep '^POSTGRES_USER=' ../../.env | cut -d= -f2)"
