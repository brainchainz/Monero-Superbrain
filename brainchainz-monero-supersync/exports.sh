# Monero SuperSync
#
# Node connection is automatic. The official Monero app's exports.sh sources its
# own .env, so APP_MONERO_NODE_IP, APP_MONERO_RPC_PORT, APP_MONERO_RPC_USER and
# APP_MONERO_RPC_PASS are already in the environment by the time this runs,
# provided umbrel-app.yml declares monero as a dependency. The fallbacks below
# exist only so the app still starts if that app is missing or renamed.
#
# APP_MONERO_RPC_PORT follows the node's network: 18081 on mainnet, 28081 on
# testnet, 38081 on stagenet. Reading it rather than hardcoding is what lets
# SuperSync follow a stagenet node with no edit here.
#
# Paths use EXPORTS_APP_DIR, not APP_DATA_DIR. APP_DATA_DIR is empty at the time
# exports.sh is sourced, so writing to "${APP_DATA_DIR}/..." here would resolve
# to the filesystem root. Compose is a later phase and APP_DATA_DIR is correct
# there, which is why docker-compose.yml still uses it.

export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"

# Change SUBNET_ID if Docker reports a pool overlap on install.
export SUBNET_ID="41"

# Host port. Namespaced so it cannot collide with another app's variables.
# APP_HOST and APP_PORT are deliberately not exported: bare names leak into
# every other app's compose interpolation. They are set on the app_proxy
# service in docker-compose.yml instead.
export APP_MONERO_SUPERSYNC_PORT="4051"

# Monero node, supplied by the official Monero app
export APP_MONERO_NODE_IP="${APP_MONERO_NODE_IP:-monero_monerod_1}"
export APP_MONERO_RPC_PORT="${APP_MONERO_RPC_PORT:-18081}"
export APP_MONERO_RPC_USER="${APP_MONERO_RPC_USER:-monero}"
export APP_MONERO_RPC_PASS="${APP_MONERO_RPC_PASS:-monero}"

# Display currency for the balance
export APP_MONERO_SUPERSYNC_FIAT="${APP_MONERO_SUPERSYNC_FIAT:-USD}"

# APP_SEED is the app's own secret, used to sign device sessions. It is
# generated once and kept, because regenerating it would unpair every device.
# It is not a wallet secret and protects no funds.
if [ -z "${APP_SEED:-}" ]; then
    APP_SEED_FILE="${EXPORTS_APP_DIR}/.app_seed"
    if [ -f "${APP_SEED_FILE}" ]; then
        export APP_SEED=$(cat "${APP_SEED_FILE}")
    else
        APP_SEED_VALUE=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | xxd -p | tr -d '\n')
        echo "${APP_SEED_VALUE}" > "${APP_SEED_FILE}"
        chmod 600 "${APP_SEED_FILE}" 2>/dev/null || true
        export APP_SEED="${APP_SEED_VALUE}"
    fi
fi

# Wallet files, password files and the database live here. The container runs as
# uid 1000, matching the umbrel user, so it can write its own data.
mkdir -p "${EXPORTS_APP_DIR}/data/wallets" 2>/dev/null || true
chmod 700 "${EXPORTS_APP_DIR}/data/wallets" 2>/dev/null || true
