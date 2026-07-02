# Brainchainz App Store for Umbrel

Community app store for [Umbrel OS](https://umbrel.com) featuring Monero-powered applications.

## Apps

| | App | Description |
|---|---|---|
| <img src="https://raw.githubusercontent.com/brainchainz/Monero-Superbrain/main/brainchainz-monero-superbrain/icon.png" width="52"> | **Monero Superbrain** | Decentralized Monero mining with P2Pool, XMRig, and a web dashboard. Connect your own miners over LAN or Tailscale, with themes, an earnings tracker, and fleet management. |
| <img src="https://raw.githubusercontent.com/brainchainz/Monero-Superbrain/main/brainchainz-monero-superpay/icon.png" width="52"> | **Monero SuperPay** | Self-hosted Monero point-of-sale. Product catalog, shopping cart, multi-device checkout, order tracking, and sales analytics. View-only wallet, so your spend keys never leave your device. |
| <img src="https://raw.githubusercontent.com/brainchainz/Monero-Superbrain/main/brainchainz-monero-space/icon.png" width="52"> | **MoneroSpace** | Self-hosted Monero block explorer and mempool visualizer based on the mempool.space interface. Reads public chain data from your node, and no wallet data ever leaves it. |
| <img src="https://raw.githubusercontent.com/brainchainz/Monero-Superbrain/main/brainchainz-monero-superstress/icon.png" width="52"> | **Monero Superstress** | Run a full Monero FCMP++ stressnet node routed entirely through Tor. Includes a wallet lab for creating wallets, sending test transactions, and stress-testing the next privacy upgrade. |
| <img src="https://raw.githubusercontent.com/brainchainz/Monero-Superbrain/main/brainchainz-monero-superatomic/icon.png" width="52"> | **Monero SuperAtomic** | Automated Swap Backend for XMR/BTC atomic swaps. Provide Monero liquidity to the Eigen network, with a dashboard for funding, swaps, balances, withdrawals, and encrypted backup and restore. |

## Install

1. Open your Umbrel dashboard
2. Go to **App Store** > **Community App Stores**
3. Click **Add** and paste: `https://github.com/brainchainz/Monero-Superbrain`
4. Browse and install apps from the **Brainchainz** store

Every app connects to the official **Monero** app, so install that first. MoneroSpace and Monero SuperAtomic also use **Bitcoin** and **Electrs** (SuperAtomic requires them).

## Connecting External Miners (Superbrain)

Point any XMRig miner on your network to your Umbrel:

```
xmrig -o umbrel.local:8888 -u "Rig Name" -p x
```

Check the Mining Fleet tab in the dashboard for full instructions.

## Source and Licensing

Monero SuperAtomic's swap engine is a GPLv3 fork of
[eigenwallet/core](https://github.com/eigenwallet/core). The complete corresponding
source of the modified engine shipped in the app's Docker images is published at
[github.com/brainchainz/eigenwallet-core](https://github.com/brainchainz/eigenwallet-core),
including every patch and the CI workflow that builds the exact binaries.

## Support

Open an issue: [github.com/brainchainz/Monero-Superbrain/issues](https://github.com/brainchainz/Monero-Superbrain/issues)

---

*Beta, feedback welcome.*
