#!/usr/bin/env bash
# scripts/listmonk/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

set -a; source "${ENV_FILE}"; set +a

echo "[listmonk] Starting setup..."

if ! docker info > /dev/null 2>&1; then
  echo "[listmonk] ERROR: Docker is not running." >&2
  exit 1
fi

# ── Create listmonk DB if it does not exist ───────────────────────────────────
echo "[listmonk] Ensuring database '${LISTMONK_DB_NAME}' exists on ${LISTMONK_DB_HOST}:${LISTMONK_DB_PORT}..."
docker run --rm \
  --add-host "host.docker.internal:host-gateway" \
  -e PGPASSWORD="${LISTMONK_DB_PASSWORD}" \
  -e PGSSLMODE=disable \
  "${POSTGRES_IMAGE}" \
  psql \
    -h "${LISTMONK_DB_HOST}" \
    -p "${LISTMONK_DB_PORT}" \
    -U "${LISTMONK_DB_USER}" \
    -d postgres \
    -c "SELECT 'exists' FROM pg_database WHERE datname='${LISTMONK_DB_NAME}'" \
    | grep -q exists \
  || docker run --rm \
    --add-host "host.docker.internal:host-gateway" \
    -e PGPASSWORD="${LISTMONK_DB_PASSWORD}" \
    -e PGSSLMODE=disable \
    "${POSTGRES_IMAGE}" \
    psql \
      -h "${LISTMONK_DB_HOST}" \
      -p "${LISTMONK_DB_PORT}" \
      -U "${LISTMONK_DB_USER}" \
      -d postgres \
      -c "CREATE DATABASE \"${LISTMONK_DB_NAME}\";"
echo "[listmonk] Database '${LISTMONK_DB_NAME}' is ready."

# ── Bring up listmonk ─────────────────────────────────────────────────────────
mkdir -p "${DIR}/volumes/uploads"
cd "${DIR}"
docker compose --env-file "${ENV_FILE}" up -d --pull always

echo "[listmonk] Done."
echo "[listmonk] URL: http://localhost:${LISTMONK_PORT%%:*}"
echo "[listmonk] Admin: ${LISTMONK_ADMIN_USER}"
