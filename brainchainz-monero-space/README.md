# MoneroSpace for Umbrel

Self-hosted Monero block explorer and mempool visualizer for Umbrel.

## What it does

MoneroSpace connects to your existing [Umbrel Monero Node](https://apps.umbrel.com/app/monero) and provides a web dashboard for exploring blocks, transactions, fees, and mempool statistics. It is based on [monerospace-org](https://github.com/n0/monerospace-org), a Monero retarget of the mempool.space UI.

## Requirements

- Umbrel with the official **Monero Node** app installed and synced.

## Connection

The app automatically reads RPC credentials from the Monero node's `.env` file and connects via HTTP Digest authentication.

## Ports

- Umbrel app proxy port: **3008**
- Internal subnet: **10.99.30.0/24**

## Support

Open an issue at https://github.com/n0/monerospace-org/issues or the brainchainz store repo.
