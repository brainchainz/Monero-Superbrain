#!/bin/bash
# MoneroSpace — Umbrel exports.sh
# Sourced by umbreld with strict mode (set -euo pipefail).
# Every APP_* variable uses a fallback to avoid unbound errors.

# ── Core Umbrel variables ────────────────────────────────────────────────────

export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"
export APP_HOST="web"
export APP_PORT="80"

# ── Monerod connection ───────────────────────────────────────────────────────

# Defaults if nothing else is found
MONEROD_HOST="monero_monerod_1"
MONEROD_PORT="18081"
MONEROD_USER=""
MONEROD_PASS=""

# Auto-load credentials from the official Umbrel Monero node app
MONERO_APP_ENV="/home/umbrel/umbrel/app-data/monero/.env"
if [ -f "$MONERO_APP_ENV" ]; then
    # shellcheck source=/dev/null
    . "$MONERO_APP_ENV"
    MONEROD_USER="${APP_MONERO_RPC_USER:-$MONEROD_USER}"
    MONEROD_PASS="${APP_MONERO_RPC_PASS:-$MONEROD_PASS}"
fi

# Allow user-provided overrides from Umbrel UI (future config fields)
MONEROD_HOST="${APP_MONEROD_HOST:-$MONEROD_HOST}"
MONEROD_PORT="${APP_MONEROD_PORT:-$MONEROD_PORT}"
MONEROD_USER="${APP_MONEROD_USER:-$MONEROD_USER}"
MONEROD_PASS="${APP_MONEROD_PASS:-$MONEROD_PASS}"

# ── Write container env file ─────────────────────────────────────────────────

mkdir -p "${APP_DATA_DIR}"
cat > "${APP_DATA_DIR}/.env" << EOF
MONEROD_RPC_URL=http://${MONEROD_HOST}:${MONEROD_PORT}
MONEROD_RPC_USER=${MONEROD_USER}
MONEROD_RPC_PASSWORD=${MONEROD_PASS}
MONEROD_RPC_TIMEOUT_MS=10000
MONEROD_RPC_FALLBACK_URLS=
MONERO_WALLET_RPC_URL=
MONERO_WALLET_RPC_USER=
MONERO_WALLET_RPC_PASSWORD=
XMR_POLL_MS=3000
EOF

echo "[monero-space] exports.sh complete"
