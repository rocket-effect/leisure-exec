#!/usr/bin/env bash
# scripts/miniflux/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

set -a; source "${ENV_FILE}"; set +a

echo "[miniflux] Starting setup..."

if ! docker info > /dev/null 2>&1; then
  echo "[miniflux] ERROR: Docker is not running." >&2
  exit 1
fi

# ── Create miniflux DB if it does not exist ───────────────────────────────────
echo "[miniflux] Ensuring database '${MINIFLUX_DB_NAME}' exists on ${MINIFLUX_DB_HOST}:${MINIFLUX_DB_PORT}..."
docker run --rm \
  --add-host "host.docker.internal:host-gateway" \
  -e PGPASSWORD="${MINIFLUX_DB_PASSWORD}" \
  -e PGSSLMODE=disable \
  "${POSTGRES_IMAGE}" \
  psql \
    -h "${MINIFLUX_DB_HOST}" \
    -p "${MINIFLUX_DB_PORT}" \
    -U "${MINIFLUX_DB_USER}" \
    -d postgres \
    -c "SELECT 'exists' FROM pg_database WHERE datname='${MINIFLUX_DB_NAME}'" \
    | grep -q exists \
  || docker run --rm \
    --add-host "host.docker.internal:host-gateway" \
    -e PGPASSWORD="${MINIFLUX_DB_PASSWORD}" \
    -e PGSSLMODE=disable \
    "${POSTGRES_IMAGE}" \
    psql \
      -h "${MINIFLUX_DB_HOST}" \
      -p "${MINIFLUX_DB_PORT}" \
      -U "${MINIFLUX_DB_USER}" \
      -d postgres \
      -c "CREATE DATABASE \"${MINIFLUX_DB_NAME}\";"
echo "[miniflux] Database '${MINIFLUX_DB_NAME}' is ready."

# ── Bring up miniflux ─────────────────────────────────────────────────────────
cd "${DIR}"
docker compose --env-file "${ENV_FILE}" up -d --pull always

echo "[miniflux] Done."
