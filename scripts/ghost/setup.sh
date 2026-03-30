#!/usr/bin/env bash
# scripts/ghost/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

# Load all vars so we can use them directly
set -a; source "${ENV_FILE}"; set +a

echo "[ghost] Checking Docker..."
if ! docker info &>/dev/null; then
  echo "[ghost] ERROR: Docker is not running." >&2
  exit 1
fi

# ── Create Ghost DB via direct connection ─────────────────────────────────────
# Spins up a throwaway mysql_client container that connects to GHOST_DB_HOST:GHOST_DB_PORT
# using Ghost's own credentials — no assumption about which container is running.
# echo "[ghost] Ensuring database '${GHOST_DB_NAME}' exists on ${GHOST_DB_HOST}:${GHOST_DB_PORT}..."
# docker run --rm \
#   --add-host "host.docker.internal:host-gateway" \
#   "${MYSQL_IMAGE}" \
#   mysql
#     -h "${GHOST_DB_HOST}" \
#     -P "${GHOST_DB_PORT}" \
#     -u "${GHOST_DB_USER}" \
#     -p"${GHOST_DB_PASSWORD}" \
#     --connect-timeout=10 \
#     -e "CREATE DATABASE IF NOT EXISTS \`${GHOST_DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
# echo "[ghost] Database '${GHOST_DB_NAME}' is ready."

# ── Bring up Ghost ────────────────────────────────────────────────────────────
echo "[ghost] Pulling images and starting containers..."
docker compose \
  --env-file "${ENV_FILE}" \
  up -d --pull always

echo "[ghost] Done."
echo "[ghost] URL: ${GHOST_URL}"

