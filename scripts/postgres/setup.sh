#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

set -a; source "$ENV_FILE"; set +a

echo "[postgres] Starting PostgreSQL standalone server..."

if ! docker info > /dev/null 2>&1; then
  echo "[postgres] ERROR: Docker is not running." >&2
  exit 1
fi

cd "$SCRIPT_DIR"
docker compose --env-file "$ENV_FILE" up -d --pull always

echo "[postgres] Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker exec "${POSTGRES_CONTAINER}" pg_isready -h 127.0.0.1 -U "${POSTGRES_USER}" -q 2>/dev/null; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -eq 0 ]; then
    echo "[postgres] ERROR: PostgreSQL did not become ready in time." >&2
    exit 1
  fi
  sleep 2
done

echo "[postgres] PostgreSQL is up."
echo "[postgres]   Host:    127.0.0.1:${POSTGRES_PORT%%:*}"
echo "[postgres]   User:    ${POSTGRES_USER}"
echo "[postgres]   Connect: psql -h 127.0.0.1 -p ${POSTGRES_PORT%%:*} -U ${POSTGRES_USER}"
