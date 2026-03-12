# Umbrel Environment
export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"

# Network configuration — CHANGE SUBNET_ID if you get "pool overlaps" errors
export SUBNET_ID="23"

# App Proxy Configuration for Umbrel Reverse Proxy
export APP_HOST="web"
export APP_PORT="3033"
export APP_MONERO_SUPERPAY_PORT="3033"

# Merchant Configuration
export APP_MONERO_SUPERPAY_FIAT="USD"
export APP_MONERO_SUPERPAY_BUSINESS_NAME="Monero SuperPay"

# Monero Node Connection
# Try 'monero' first as it is the standard Umbrel alias, fallback to container name
export APP_MONERO_NODE_IP="${APP_MONERO_NODE_IP:-monero_monerod_1}"
export APP_MONERO_RPC_PORT="18081"

# Dynamically source Monero RPC credentials from official Monero app
UMBREL_MONERO_ENV="${APP_DATA_DIR}/../monero/.env"
if [ -f "${UMBREL_MONERO_ENV}" ]; then
    # Extract credentials — handle both 'export VAR=val' and 'VAR=val' formats
    # Strip the 'export ' prefix first, then extract value after '=', then strip any quotes
    EXTRACTED_USER=$(grep "APP_MONERO_RPC_USER=" "${UMBREL_MONERO_ENV}" | sed 's/^export //' | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    EXTRACTED_PASS=$(grep "APP_MONERO_RPC_PASS=" "${UMBREL_MONERO_ENV}" | sed 's/^export //' | cut -d '=' -f2- | tr -d '"' | tr -d "'")

    if [ ! -z "${EXTRACTED_USER}" ]; then
        export APP_MONERO_RPC_USER="${EXTRACTED_USER}"
    fi
    if [ ! -z "${EXTRACTED_PASS}" ]; then
        export APP_MONERO_RPC_PASS="${EXTRACTED_PASS}"
    fi
fi

# Final fallbacks
export APP_MONERO_RPC_USER="${APP_MONERO_RPC_USER:-monero}"
export APP_MONERO_RPC_PASS="${APP_MONERO_RPC_PASS:-monero}"

# Generate APP_SEED if not already set (replaces generateSecret from umbrel-app.yml)
if [ -z "${APP_SEED:-}" ]; then
    APP_SEED_FILE="${APP_DATA_DIR}/.app_seed"
    if [ -f "${APP_SEED_FILE}" ]; then
        export APP_SEED=$(cat "${APP_SEED_FILE}")
    else
        export APP_SEED=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | xxd -p | tr -d '\n')
        mkdir -p "${APP_DATA_DIR}"
        echo "${APP_SEED}" > "${APP_SEED_FILE}"
    fi
fi
