#!/bin/bash

# Network configuration for Umbrel subnet
# CHANGE THIS IF YOU GET "POOL OVERLAPS" ERRORS
export SUBNET_ID="212"

export APP_MONERO_SUPERBRAIN_IP="10.21.${SUBNET_ID}.1"
export APP_MONERO_SUPERBRAIN_MONEROD_IP="10.21.${SUBNET_ID}.2"
export APP_MONERO_SUPERBRAIN_P2POOL_IP="10.21.${SUBNET_ID}.3"
export APP_MONERO_SUPERBRAIN_PROXY_IP="10.21.${SUBNET_ID}.4"
export APP_MONERO_SUPERBRAIN_XMRIG_IP="10.21.${SUBNET_ID}.5"

# App Proxy Configuration for Umbrel Reverse Proxy
export APP_HOST="dashboard"    # Service to proxy to
export APP_PORT="3000"         # Dashboard port

# Mining Configuration (Monero merchant test wallet)
export WALLET_ADDRESS="43sEimq64TtLoBaEzzxf7wVd4XcZPuGtNRP7zhT7WAgB3th9dvCrJMad99pZNKBRDmJXXXUxeZie7W5tsm7TWVrPHbxvins"
export P2POOL_DIFFICULTY="0"    # 0 = auto difficulty
export XMRIG_THREADS="1"       # Default: 1 thread

# Monero Node Connection (Manually set for side-loading)
# If running as an official Umbrel App, these are injected automatically.
# For testing: 10.21.21.8 is typically the Monero Node IP in Umbrel, but it varies!
# You may need to check your Umbrel's Docker network or use the Tor address.
# RPC Port is usually 18081, ZMQ is 18083.
export APP_MONERO_NODE_IP="${APP_MONERO_NODE_IP:-10.21.21.8}"
export APP_MONERO_RPC_PORT="${APP_MONERO_RPC_PORT:-18081}"
export APP_MONERO_ZMQ_PORT="${APP_MONERO_ZMQ_PORT:-18083}"
export APP_MONERO_RPC_USER="${APP_MONERO_RPC_USER:-monero}"
export APP_MONERO_RPC_PASS="${APP_MONERO_RPC_PASS:-monero}"

# Umbrel Environment
export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"