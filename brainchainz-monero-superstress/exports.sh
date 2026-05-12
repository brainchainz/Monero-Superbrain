#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Monero Superstress — Umbrel exports.sh
#
# Sourced by umbreld with strict mode (set -euo pipefail).
# Every variable MUST use ${VAR:-default} to avoid unbound errors.
# ═══════════════════════════════════════════════════════════════════════════════

# ── Core Umbrel variables ────────────────────────────────────────────────────

export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"
export APP_HOST="web"
export APP_PORT="4050"

# ── APP_SEED (community apps can't use generateSecret) ───────────────────────

if [ -z "${APP_SEED:-}" ]; then
    APP_SEED_FILE="${APP_DATA_DIR}/.app_seed"
    if [ -f "${APP_SEED_FILE}" ]; then
        export APP_SEED=$(cat "${APP_SEED_FILE}")
    else
        export APP_SEED=$(openssl rand -hex 32 2>/dev/null \
            || head -c 64 /dev/urandom | xxd -p | tr -d '\n')
        mkdir -p "${APP_DATA_DIR}"
        echo "${APP_SEED}" > "${APP_SEED_FILE}"
    fi
fi
