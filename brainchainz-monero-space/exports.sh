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

mkdir -p "$APP_DATA_DIR"

echo "MONEROD_RPC_URL=http://$MONEROD_HOST:$MONEROD_PORT" > "$APP_DATA_DIR/.env"
echo "MONEROD_RPC_USER=$MONEROD_USER" >> "$APP_DATA_DIR/.env"
echo "MONEROD_RPC_PASSWORD=$MONEROD_PASS" >> "$APP_DATA_DIR/.env"
echo "MONEROD_RPC_TIMEOUT_MS=10000" >> "$APP_DATA_DIR/.env"
echo "MONEROD_RPC_FALLBACK_URLS=" >> "$APP_DATA_DIR/.env"
echo "MONERO_WALLET_RPC_URL=" >> "$APP_DATA_DIR/.env"
echo "MONERO_WALLET_RPC_USER=" >> "$APP_DATA_DIR/.env"
echo "MONERO_WALLET_RPC_PASSWORD=$MONEROD_PASS" >> "$APP_DATA_DIR/.env"
echo "XMR_POLL_MS=3000" >> "$APP_DATA_DIR/.env"

echo "[monero-space] exports.sh complete"
