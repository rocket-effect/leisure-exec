#!/usr/bin/env bash
# scripts/rss-feed-builder/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
ENV_FILE="${ROOT}/.env"
REPO_DIR="${DIR}/repo"

# Load all vars (including GITHUB_TOKEN) into the environment
set -a; source "${ENV_FILE}"; set +a

echo "[rss-feed-builder] Checking Docker..."
if ! docker info &>/dev/null; then
  echo "[rss-feed-builder] ERROR: Docker is not running." >&2
  exit 1
fi

# ── Clone or update repo ──────────────────────────────────────────────────────
if [[ -d "${REPO_DIR}/.git" ]]; then
  echo "[rss-feed-builder] Repo already present — pulling latest changes..."
  git -C "${REPO_DIR}" pull
else
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "[rss-feed-builder] ERROR: GITHUB_TOKEN is not set in ${ENV_FILE}." >&2
    exit 1
  fi
  echo "[rss-feed-builder] Cloning"
  git clone "https://${GITHUB_TOKEN}@github.com/rocket-effect/rss-feed-builder.git" "${REPO_DIR}"
fi

# ── Bring up the service ──────────────────────────────────────────────────────
echo "[rss-feed-builder] Starting containers..."
cd "${REPO_DIR}"
docker compose \
  --env-file "${ENV_FILE}" \
  up -d --pull always

echo "[rss-feed-builder] Done."
