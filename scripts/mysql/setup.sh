#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

set -a; source "$ENV_FILE"; set +a

echo "[mysql] Starting MySQL standalone server..."

if ! docker info > /dev/null 2>&1; then
  echo "[mysql] ERROR: Docker is not running." >&2
  exit 1
fi

cd "$SCRIPT_DIR"
docker compose --env-file "$ENV_FILE" up -d --pull always

echo "[mysql] Waiting for MySQL to be ready..."
RETRIES=30
until docker exec "${MYSQL_CONTAINER}" mysqladmin ping -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -eq 0 ]; then
    echo "[mysql] ERROR: MySQL did not become ready in time." >&2
    exit 1
  fi
  sleep 2
done

echo "[mysql] MySQL is up."
echo "[mysql]   Host:    127.0.0.1:${MYSQL_PORT%%:*}"
echo "[mysql]   Root:    root / ${MYSQL_ROOT_PASSWORD}"
echo "[mysql]   User:    ${MYSQL_USER} / ${MYSQL_PASSWORD}"
echo "[mysql]   Connect: mysql -h 127.0.0.1 -P ${MYSQL_PORT%%:*} -uroot -p'${MYSQL_ROOT_PASSWORD}'"
