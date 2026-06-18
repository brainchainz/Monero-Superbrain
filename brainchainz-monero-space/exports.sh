#!/bin/bash
# MoneroSpace exports.sh

export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"
export APP_HOST="web"
export APP_PORT="80"

MONEROD_HOST="monero_monerod_1"
MONEROD_PORT="18081"
MONEROD_USER=""
MONEROD_PASS=""

MONERO_APP_ENV="/home/umbrel/umbrel/app-data/monero/.env"
if [ -f "$MONERO_APP_ENV" ]; then
    # shellcheck source=/dev/null
    . "$MONERO_APP_ENV"
    MONEROD_USER="${APP_MONERO_RPC_USER:-$MONEROD_USER}"
    MONEROD_PASS="${APP_MONERO_RPC_PASS:-$MONEROD_PASS}"
fi

MONEROD_HOST="${APP_MONEROD_HOST:-$MONEROD_HOST}"
MONEROD_PORT="${APP_MONEROD_PORT:-$MONEROD_PORT}"
MONEROD_USER="${APP_MONEROD_USER:-$MONEROD_USER}"
MONEROD_PASS="${APP_MONEROD_PASS:-$MONEROD_PASS}"

mkdir -p "${APP_DATA_DIR}"

cat > "${APP_DATA_DIR}/.env" << EOENV
MONEROD_RPC_URL=http://${MONEROD_HOST}:${MONEROD_PORT}
MONEROD_RPC_USER=${MONEROD_USER}
MONEROD_RPC_PASSWORD=${MONE...EOENV

echo "[monero-space] exports.sh complete"
