# Monero SuperAtomic (Eigen ASB) — Umbrel exports
#
# Runs on the Umbrel host during app install/start. It allocates the data
# directory, resolves the Monero node and Electrs endpoints, and generates the
# secrets and config.toml that the container expects under /data.

DATA_DIR="${EXPORTS_APP_DIR}/data"
ENV_FILE="${EXPORTS_APP_DIR}/.env"
CONFIG_FILE="${DATA_DIR}/config.toml"

mkdir -p "${DATA_DIR}/logs"

# --- Monero node connection ---------------------------------------------------
# umbrel monerod enforces HTTP digest auth on every RPC port, but the Eigen ASB
# node pool cannot send credentials. So the container runs a small digest-auth
# proxy (scripts/monero-proxy.mjs) that the ASB talks to unauthenticated on
# 127.0.0.1:18090; the proxy injects the auth and forwards to the node by DNS
# name (monero_monerod_1, IP-change-proof). We read the node's RPC credentials
# from the Monero app here and pass them to the proxy via the compose file.
export APP_MONERO_RPC_PORT="${APP_MONERO_RPC_PORT:-18081}"

MONERO_ENV="${EXPORTS_APP_DIR}/../monero/.env"
if [ -f "${MONERO_ENV}" ]; then
    EXTRACTED_USER=$(grep "APP_MONERO_RPC_USER=" "${MONERO_ENV}" | sed 's/^export //' | cut -d '=' -f2- | tr -d "\"'")
    EXTRACTED_PASS=$(grep "APP_MONERO_RPC_PASS=" "${MONERO_ENV}" | sed 's/^export //' | cut -d '=' -f2- | tr -d "\"'")
    [ -n "${EXTRACTED_USER}" ] && export APP_MONERO_RPC_USER="${EXTRACTED_USER}"
    [ -n "${EXTRACTED_PASS}" ] && export APP_MONERO_RPC_PASS="${EXTRACTED_PASS}"
fi
export APP_MONERO_RPC_USER="${APP_MONERO_RPC_USER:-monero}"
export APP_MONERO_RPC_PASS="${APP_MONERO_RPC_PASS:-monero}"

# --- Electrs connection -------------------------------------------------------
export APP_ELECTRS_NODE_IP="${APP_ELECTRS_NODE_IP:-10.21.21.10}"
export APP_ELECTRS_NODE_PORT="${APP_ELECTRS_NODE_PORT:-50001}"

# --- Secrets (generated once) -------------------------------------------------
# IMPORTANT: every variable here is namespaced (GEN_*). exports.sh is sourced by
# umbreld into the environment it uses to interpolate the compose file, so a bare
# name like JWT_SECRET would clobber the global Umbrel app_proxy JWT_SECRET and
# break session auth ("invalid signature") on this app.
if [ ! -f "${ENV_FILE}" ]; then
    # The dashboard password is NOT generated here: the user sets it themselves
    # on first launch in the UI, and the API stores the bcrypt hash at
    # data/dashboard-password-hash. So no host-side bcrypt is needed.
    GEN_RPC_PASSWORD="$(openssl rand -hex 32)"
    GEN_JWT_SECRET="$(openssl rand -hex 32)"

    # ASB RPC auth verifier file format (see swap-env/src/rpc_auth.rs):
    #   "<salt_hex>:<HMAC_SHA256(key=salt_hex_string, msg=password)_hex>"
    # The dashboard authenticates to the ASB JSON-RPC with the plaintext
    # RPC password as a Bearer token.
    GEN_RPC_SALT="$(openssl rand -hex 16)"
    GEN_RPC_HMAC="$(printf '%s' "${GEN_RPC_PASSWORD}" | openssl dgst -sha256 -hmac "${GEN_RPC_SALT}" | awk '{print $NF}')"

    printf '%s\n' "${GEN_RPC_PASSWORD}" > "${DATA_DIR}/rpc-password"
    printf '%s\n' "${GEN_JWT_SECRET}"   > "${DATA_DIR}/jwt-secret"
    printf '%s:%s\n' "${GEN_RPC_SALT}" "${GEN_RPC_HMAC}" > "${DATA_DIR}/rpc-auth"
    chmod 600 "${DATA_DIR}/rpc-password" "${DATA_DIR}/jwt-secret" "${DATA_DIR}/rpc-auth"

    # Marker file so secrets are only generated on first run.
    printf 'APP_MONERO_SUPERATOMIC_INITIALIZED=1\n' > "${ENV_FILE}"
    chmod 600 "${ENV_FILE}"
fi

# --- Config (generated once) --------------------------------------------------
if [ ! -f "${CONFIG_FILE}" ]; then
    cat > "${CONFIG_FILE}" <<CONFIG
[data]
dir = "/data"

[network]
# Clearnet listener off by default for privacy: the maker is reachable only over
# its Tor hidden service (register_hidden_service below). Enable clearnet in the
# dashboard Config tab if you specifically want it.
listen = []
# Current eigenwallet discovery set. Each operator is listed twice: a clearnet
# WSS address and its Tor onion service. On a Tor-only node the /onion3/ entries
# are dialed natively over Tor, which is far more reliable than reaching a
# clearnet rendezvous through Tor. Kept in sync with eigenwallet/core defaults.
rendezvous_point = [
    "/dns4/discovery.eigenwallet.org/tcp/443/wss/p2p/12D3KooWGRvf7qVQDrNR5nfYD6rKrbgeTi9x8RrbdxbmsPvxL4mw",
    "/onion3/3xl2zfur4tpebogsrgn3l7l2illzkhwi3755jplmycmn4q77nxsrl6qd:8888/p2p/12D3KooWGRvf7qVQDrNR5nfYD6rKrbgeTi9x8RrbdxbmsPvxL4mw",
    "/dns4/rendezvous.atomicworld.fun/tcp/443/wss/p2p/12D3KooWMc39w7bZz4RLmJKuUiK9YkbKoEHACZWcL71XNns5dPuD",
    "/onion3/m2iuwp3fvdlqtlqqaz3egrzjl5uehmdhjgmzhznvjoudljl2xzjaomyd:8890/p2p/12D3KooWMc39w7bZz4RLmJKuUiK9YkbKoEHACZWcL71XNns5dPuD",
    "/dns4/dht.stealthswap.ninja/tcp/443/wss/p2p/12D3KooWGjcxdpsEWspGGwkQJ9BRJQjtBQFsLk36zJxrXSBPQWov",
    "/onion3/m6rboz5lv4wxldgybgox4pr4s6xci3h2exi5nogxaox762xji2gokuad:8891/p2p/12D3KooWGjcxdpsEWspGGwkQJ9BRJQjtBQFsLk36zJxrXSBPQWov",
    "/dns4/discovery2.eigenwallet.org/tcp/443/wss/p2p/12D3KooWA6cnqJpVnreBVnoro8midDL9Lpzmg8oJPoAGi7YYaamE",
    "/onion3/av2jauifny7dgpvzhsnhra3cwivf6ofaefxvwhhuh5y7hsolabehhaad:8888/p2p/12D3KooWA6cnqJpVnreBVnoro8midDL9Lpzmg8oJPoAGi7YYaamE"
]
external_addresses = []

[bitcoin]
electrum_rpc_urls = ["tcp://electrs_electrs_1:${APP_ELECTRS_NODE_PORT:-50001}"]
target_block = 1
network = "Mainnet"
use_mempool_space_fee_estimation = true

[monero]
daemon_url = "http://127.0.0.1:18090"
network = "Mainnet"

[tor]
register_hidden_service = true
# More introduction points than the default 5 give takers more Tor entry paths
# to the maker's onion service, which improves inbound reachability.
hidden_service_num_intro_points = 10

[maker]
min_buy_btc = 0.001
max_buy_btc = 0.5
ask_spread = 0.02
refund_policy = { anti_spam_deposit_ratio = 0.2 }
developer_tip = 0.01
btc_redeem_fee_multiplier = 1.0
CONFIG
fi
