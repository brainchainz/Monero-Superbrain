# Brainchainz App Store for Umbrel

Community app store for [Umbrel OS](https://umbrel.com) featuring Monero-powered applications.

## Apps

### Monero Superbrain
Decentralized Monero mining with P2Pool, XMRig, XMRig-proxy, and a web dashboard.
Connect your own miners over LAN or Tailscale. Beautiful themes, earnings tracker, and fleet management.

### Monero SuperPay
Self-hosted point-of-sale system for accepting Monero (XMR) payments.
Product catalog, shopping cart, multi-device PoS, order tracking, and sales analytics.
View-only wallet — your spend keys never leave your device.

## Install

1. Open your Umbrel dashboard
2. Go to **App Store** > **Community App Stores**
3. Click **Add** and paste: `https://github.com/brainchainz/Monero-Superbrain`
4. Browse and install apps from the **Brainchainz** store

Both apps require the official **Monero** app to be installed first.

## Connecting External Miners (Superbrain)

Point any XMRig miner on your network to your Umbrel:

```
xmrig -o umbrel.local:8888 -u "Rig Name" -p x
```

Check the Mining Fleet tab in the dashboard for full instructions.

## Support

Open an issue: [github.com/brainchainz/Monero-Superbrain/issues](https://github.com/brainchainz/Monero-Superbrain/issues)

---

*Beta — feedback welcome.*
