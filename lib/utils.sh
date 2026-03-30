#!/usr/bin/env bash
# lib/utils.sh — Common utility functions

# Guard against double-sourcing
[[ -n "${_UTILS_LOADED:-}" ]] && return 0
_UTILS_LOADED=1

# Source logger if not already loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/logger.sh
source "${SCRIPT_DIR}/logger.sh"

# ── Dependency checks ──────────────────────────────────────────────────────────

# check_cmd <command> [install-hint]
# Returns 0 if found, 1 if missing (logs error with optional hint).
check_cmd() {
  local cmd="$1" hint="${2:-}"
  if command -v "$cmd" &>/dev/null; then
    log_debug "Dependency found: $cmd ($(command -v "$cmd"))"
    return 0
  fi
  log_error "Required command not found: '$cmd'"
  [[ -n "$hint" ]] && log_error "  Install hint: $hint"
  return 1
}

# require_cmds <cmd1> [cmd2 ...]
# Exits with error if any command is missing.
require_cmds() {
  local failed=0
  for cmd in "$@"; do
    check_cmd "$cmd" || failed=1
  done
  [[ $failed -eq 1 ]] && {
    log_error "One or more required commands are missing. Aborting."
    exit 1
  }
}

# ── JSON helpers (require jq) ──────────────────────────────────────────────────

# json_get <file> <jq-filter>
# Outputs the value; exits 1 if file missing or key null.
json_get() {
  local file="$1" filter="$2"
  if [[ ! -f "$file" ]]; then
    log_error "Config file not found: $file"
    return 1
  fi
  local val
  val=$(jq -r "$filter" "$file" 2>/dev/null)
  if [[ "$val" == "null" || -z "$val" ]]; then
    log_debug "json_get: '$filter' returned null/empty in $file"
    return 1
  fi
  echo "$val"
}

# json_array <file> <jq-filter>
# Prints each element of a JSON array on its own line.
json_array() {
  local file="$1" filter="$2"
  if [[ ! -f "$file" ]]; then
    log_error "Config file not found: $file"
    return 1
  fi
  jq -r "${filter}[]" "$file" 2>/dev/null
}

# ── Docker helpers ─────────────────────────────────────────────────────────────

# require_docker
# Ensures Docker daemon is running. Exits if not.
require_docker() {
  check_cmd docker "Install Docker Desktop: https://docs.docker.com/get-docker/" || exit 1
  if ! docker info &>/dev/null; then
    log_error "Docker daemon is not running. Please start Docker and retry."
    exit 1
  fi
  log_ok "Docker daemon is running."
}

# require_compose
# Ensures 'docker compose' (v2 plugin) is available. Exits if not.
require_compose() {
  if ! docker compose version &>/dev/null; then
    log_error "'docker compose' plugin not found."
    log_error "  Install hint: https://docs.docker.com/compose/install/"
    exit 1
  fi
  log_ok "Docker Compose $(docker compose version --short 2>/dev/null) available."
}

# compose_up <platform_dir>
# Runs 'docker compose up -d --pull always' in the given directory.
compose_up() {
  local dir="$1"
  log_info "docker compose up: $dir"
  docker compose -f "${dir}/docker-compose.yml" up -d --pull always
}

# compose_down <platform_dir> [--volumes]
# Runs 'docker compose down' in the given directory.
# Pass --volumes to also remove named volumes.
compose_down() {
  local dir="$1"
  local extra_flags="${2:-}"
  log_info "docker compose down: $dir"
  # shellcheck disable=SC2086
  docker compose -f "${dir}/docker-compose.yml" down $extra_flags
}

# docker_container_exists <name>
docker_container_exists() {
  docker ps -a --format '{{.Names}}' | grep -qx "$1"
}

# docker_container_running <name>
docker_container_running() {
  docker ps --format '{{.Names}}' | grep -qx "$1"
}

# docker_stop_remove <name>
# Stops and removes a container if it exists.
docker_stop_remove() {
  local name="$1"
  if docker_container_running "$name"; then
    log_info "Stopping container: $name"
    docker stop "$name" &>/dev/null
  fi
  if docker_container_exists "$name"; then
    log_info "Removing container: $name"
    docker rm "$name" &>/dev/null
  fi
}

# ── Misc ───────────────────────────────────────────────────────────────────────

# confirm <message>
# Prompts the user for y/n. Returns 0 for yes, 1 for no.
confirm() {
  local msg="${1:-Continue?} [y/N] "
  read -r -p "$msg" answer
  [[ "${answer,,}" =~ ^(y|yes)$ ]]
}

# retry <attempts> <delay_seconds> <command...>
# Retries a command up to N times with a delay between attempts.
retry() {
  local attempts="$1" delay="$2"
  shift 2
  local i=1
  while (( i <= attempts )); do
    "$@" && return 0
    log_warn "Attempt $i/$attempts failed. Retrying in ${delay}s..."
    sleep "$delay"
    (( i++ ))
  done
  log_error "All $attempts attempts failed for: $*"
  return 1
}
