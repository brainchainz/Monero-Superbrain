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

# Mining Configuration
# Default on fresh install: mine 100% to dev wallet (no fee to self)
DEV_WALLET_DEFAULT="43sEimq64TtLoBaEzzxf7wVd4XcZPuGtNRP7zhT7WAgB3th9dvCrJMad99pZNKBRDmJXXXUxeZie7W5tsm7TWVrPHbxvins"
if [ -z "${WALLET_ADDRESS:-}" ]; then export WALLET_ADDRESS="$DEV_WALLET_DEFAULT"; fi
if [ -z "${DEV_WALLET:-}" ]; then export DEV_WALLET="$DEV_WALLET_DEFAULT"; fi
export DEV_FEE_PERCENT="${DEV_FEE_PERCENT:-1}"
export P2POOL_CHAIN="${P2POOL_CHAIN:-main}"
export XMRIG_THREADS="${XMRIG_THREADS:-0}"

# Monero Node Connection (auto-detected by dashboard)
export APP_MONERO_NODE_IP="${APP_MONERO_NODE_IP:-monero_monerod_1}"
export APP_MONERO_RPC_PORT="${APP_MONERO_RPC_PORT:-18081}"
export APP_MONERO_ZMQ_PORT="${APP_MONERO_ZMQ_PORT:-18083}"
export APP_MONERO_RPC_USER="${APP_MONERO_RPC_USER:-monero}"
export APP_MONERO_RPC_PASS="${APP_MONERO_RPC_PASS:-monero}"

# Umbrel Environment
export APP_DATA_DIR="${APP_DATA_DIR:-$PWD/data}"
export DEVICE_DOMAIN_NAME="${DEVICE_DOMAIN_NAME:-umbrel.local}"
