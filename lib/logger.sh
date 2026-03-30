#!/usr/bin/env bash
# lib/logger.sh — Colored logging utilities

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

# ── Log Levels ─────────────────────────────────────────────────────────────────
LOG_LEVEL=${LOG_LEVEL:-INFO}   # DEBUG | INFO | WARN | ERROR

# Numeric rank for a log level — case-based for bash 3.2 / sh compatibility.
_log_rank() {
  case "$1" in
    DEBUG) echo 0 ;;
    INFO)  echo 1 ;;
    WARN)  echo 2 ;;
    ERROR) echo 3 ;;
    *)     echo 1 ;;
  esac
}

_should_log() {
  local level="$1"
  [[ $(_log_rank "$level") -ge $(_log_rank "$LOG_LEVEL") ]]
}

# ── Timestamp ──────────────────────────────────────────────────────────────────
_ts() { date "+%Y-%m-%d %H:%M:%S"; }

# ── Core log function ──────────────────────────────────────────────────────────
_log() {
  local color="$1" level="$2" prefix="$3"
  shift 3
  _should_log "$level" || return 0
  printf "${color}${BOLD}[%s]${RESET} ${color}%-7s${RESET} %s\n" \
    "$(_ts)" "$prefix" "$*"
}

# ── Public helpers ─────────────────────────────────────────────────────────────
log_debug() { _log "$WHITE"  DEBUG "DEBUG  " "$@"; }
log_info()  { _log "$CYAN"   INFO  "INFO   " "$@"; }
log_ok()    { _log "$GREEN"  INFO  "OK     " "$@"; }
log_warn()  { _log "$YELLOW" WARN  "WARN   " "$@" >&2; }
log_error() { _log "$RED"    ERROR "ERROR  " "$@" >&2; }

log_step() {
  local idx="$1" total="$2" name="$3"
  printf "\n${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
  printf "${BLUE}${BOLD}  [%d/%d]  %s${RESET}\n" "$idx" "$total" "$name"
  printf "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n\n"
}

log_banner() {
  printf "\n${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}\n"
  printf "${CYAN}${BOLD}║  %-52s║${RESET}\n" "$*"
  printf "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}\n\n"
}

log_section() {
  printf "\n${YELLOW}${BOLD}──  %s${RESET}\n" "$*"
}
