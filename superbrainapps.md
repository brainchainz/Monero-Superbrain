# The Monero Superbrain Suite: Documentation

*Self-hosted Monero software for [Umbrel](https://umbrel.com). Your box, your node, your keys. No accounts, no telemetry, no third parties in the loop.*

This document covers every app in the **Brainchainz** community app store (the "Monero Superbrain" suite): what each app does, how it works, and what you should know before you point real money at it.

Status: **beta**, actively developed. Versions listed per app. Works best on a 64-bit Umbrel box you control, ideally reachable over Tailscale.

---

## The suite at a glance

| App | What it's for | Requires |
|---|---|---|
| **Monero Superbrain** | Decentralized Monero mining (P2Pool + XMRig) with a web dashboard and miner fleet management | Monero node |
| **MoneroSpace** | Self-hosted block explorer and mempool visualizer | Monero node |
| **Monero SuperAtomic** | Automated Swap Backend: provide XMR liquidity on the Eigen network and earn maker fees | Monero node + Bitcoin + Electrs |
| **Monero SuperPay** | Self-hosted Monero point-of-sale and merchant system | Monero node (plus optional Tor) |
| **Monero Superstress** | FCMP++ stressnet node and wallet lab, for testing Monero's next privacy upgrade | nothing (self-contained, Tor-only) |

**Install:** Umbrel dashboard → App Store → Community App Stores → Add → `https://github.com/brainchainz/Monero-Superbrain`.

Install the official **Monero** app first. Most of the suite reads your node over Umbrel's internal network and never touches the public internet for chain data.

---

## Read this first (applies to everything below)

- **Everything is beta.** These apps manage real (and test) funds. Start small, verify behavior on your own box, then scale up what you actually use.
- **Your node is the backend.** Apps talk to your local Monero node (and Bitcoin/Electrs where relevant) over an internal Docker network using credentials Umbrel generated. None of the apps expose your node RPC beyond the box unless stated.
- **Access model.** Nearly every app sits behind Umbrel's own app login (the app-proxy). A few deliberately publish raw ports, such as the miner port of Superbrain and the peer port of SuperAtomic, because the clients connecting there can't complete a web login. Each app's section lists exactly what is published and why.
- **Tailscale is your friend.** Several apps assume you'll reach them at `umbrel.local` or a tailnet name, and some features (HTTPS origins, biometrics) want the tailnet name specifically.
- **Secrets and data live in `app-data`.** Per-install secrets (passwords, tokens) are generated at first launch and written owner-only under the app's data directory. Backups: see each app and the [Data, backups and updates](#data-backups-and-updates) section.
- **Updates keep your data.** App updates replace images; wallets, databases, and configuration live in per-app data volumes and upgrade in place.
- **No telemetry.** If an app contacts the outside world (P2Pool observers, the BTC network, Tor), its section says so, and several route over Tor by default.

---

## How the apps are built (shared mechanics)

All apps follow the same Umbrel packaging pattern, which is worth understanding once:

- Each app is a small set of containers: the app itself behind Umbrel's `app_proxy` (which handles login and HTTPS at the umbrel level), plus sidecars where needed (Tor proxy, wallet RPC, control proxy).
- Containers live on a private per-app Docker network. Only what must be shared joins `umbrel_main_network` (to reach your Monero node).
- Images are **pinned versions from public registries** (mostly `sirjamzalot/*` on Docker Hub; the swap engine binary ships from `ghcr.io/brainchainz`). No `:latest` surprises mid-update.
- Where an app needs to control sibling containers (start/stop mining), it does **not** get the raw Docker socket. A token-gated control-proxy sidecar holds the socket and exposes a minimal API, so a compromised dashboard can't act as host root.
- Multi-arch (amd64 + arm64) where the images allow it; the suite targets 64-bit Umbrel hardware.

---

## 1. Monero Superbrain: mining

*v1.5.2 · port 3000 (dashboard) · worker port 8888*

**What it is.** A complete decentralized Monero mining setup: P2Pool, XMRig, a connection manager for external miners, and a dashboard. Point your own rigs (or the box's CPU) at it and mine to your wallet.

**How it works.**
- P2Pool (mini chain by default) forms a local pool. XMRig-proxy lets external miners connect.
- The dashboard manages config and status. A token-gated control-proxy starts and stops components, and all P2Pool observer lookups (payouts, shares, hashrate) go **over Tor**, so your node's IP isn't exposed to observers.
- Your payout wallet is configured in the app. Fresh installs default to the dev wallet; once you set your own address, a default **1% dev fee** applies.
- Chains: `mini` (default, faster and smaller payouts), `nano`, `main`.

**What you should know.**
- Mine on the **mini** chain unless you have serious hashrate. Frequent payouts are the entire point of mini and nano.
- External miners connect with:
  `xmrig -o umbrel.local:8888 -u "Rig Name" -p x` (or your tailnet name).
- Published ports: `8888` (worker/proxy, LAN and tailnet intended), `3333` (raw stratum), `37889` (P2Pool P2P, for inbound peers).
- XMRig can use a lot of CPU. The dashboard has a thread slider. The box itself is fine for a token hashrate, but a desktop will out-hash it by miles.
- Themes exist (including community Matrix themes MTRX and NURO). Yes, really.

---

## 2. MoneroSpace: explorer

*v1.0.15 · port 3008*

**What it is.** A self-hosted Monero block explorer and mempool visualizer with the mempool.space interface language, reading chain data from *your* node.

**How it works.** A web app and proxy only. It queries your local node (handling HTTP digest auth internally) for blocks, transactions, fees, and mempool stats. No wallet data ever leaves your node. Private view keys and tx secrets stay in your browser for optional payment verification.

**What you should know.**
- It's a read-only view of public chain data via your own node. The point is not leaking your queries to someone else's explorer.
- Useful for verifying a payment you receive without handing a view key to a third party.
- Arm64 and amd64 both ship.

---

## 3. Monero SuperAtomic: liquidity provider (XMR/BTC atomic swaps)

*v0.5.0 · port 8085 (dashboard) · peer port 9939*

**What it is.** An Automated Swap Backend (ASB) for the [Eigen](https://eigenwallet.org) XMR/BTC atomic swap network, packaged for Umbrel. You provide Monero liquidity, takers swap BTC for your XMR, and you earn the spread plus fees.

**How it works.**
- The swap engine is a patched **GPLv3 fork of [eigenwallet/core](https://github.com/eigenwallet/core)**, currently upstream 5.0.2. The complete corresponding source lives at [github.com/brainchainz/eigenwallet-core](https://github.com/brainchainz/eigenwallet-core).
- The app runs the ASB plus a dashboard: funding, swap list, balances, BTC withdrawal, peer connectivity, logs, encrypted backup and restore, and config.
- It connects to your local Monero node and to your local **Bitcoin + Electrs** apps. BTC legs settle on-chain (no Lightning).
- Your ASB publishes a peer port (`9939`) so takers on the network can reach it.

**What you should know.**
- **This is your money providing liquidity.** Keep XMR (and a sliver of BTC for fees) funded in the app wallet. Funds are yours throughout; swaps are atomic.
- **5.x is breaking.** Upstream made the 5.x swap protocol incompatible with 4.x, so both peers must run 5.x to start new swaps. Old 4.x-era takers will find you again once they upgrade.
- **Back up.** The dashboard produces an encrypted wallet backup file, and you can display the seed. Restore works on fresh installs. Without a backup, a bricked box becomes a fund recovery project.
- **Uptime is income.** Swaps only fill while the app runs. A UPS and Tailscale SSH are good ideas.
- Port-forward `9939` (TCP) if you want maximum peer reachability. Tailnet works for many peers; a public port helps more.
- The 1% maker dev tip is baked into the swap pricing floor and shown in the dashboard.
- Wallet, database, and logs live in the app's data volume and upgrade in place across versions.

---

## 4. Monero SuperPay: point-of-sale

*v1.3.1 · port 3033*

**What it is.** A self-hosted, trustless Monero point-of-sale: catalog, cart, multi-device checkout, order tracking, and sales analytics. Any tablet or phone with a browser becomes a register.

**How it works.**
- A **view-only** `monero-wallet-rpc` watches your shop wallet. Your spend keys never leave your own wallet software (Feather, Cake, a hardware wallet, your choice), while SuperPay watches incoming payments via the view key.
- Devices pair by QR code. POS modes: keypad, product grid, full cart. Orders flow into real-time tracking and analytics.
- The dashboard keeps its database and uploads under app data. When Umbrel's Tor is enabled, a Tor onion hostname is picked up so customers can reach your shop without you exposing your home IP.

**What you should know.**
- You need an **existing Monero wallet** for the shop. SuperPay never holds spend keys. Keep your wallet software in reach for sweeping funds.
- Prices can be shown in fiat (rate source configurable in the app) while settlement is XMR.
- Test with a tiny payment first, then trust it with a busy Saturday market.
- Themes: Glass (default), Classic, Carbon, Ocean, Fintech.

---

## 5. Monero Superstress: FCMP++ stressnet

*v1.8.7 · port 4050*

**What it is.** A full Monero **FCMP++ stressnet** node (the test network for Monero's next-generation privacy upgrade, Full-Chain Membership Proofs) plus a wallet lab for creating wallets, sending test transactions, solo mining, and spamming the network. Everything routes through **Tor, zero clearnet**.

**How it works.** A self-contained stack: its own stressnet `monerod` (connect-only to live stressnet nodes), wallet RPCs, a spammer wallet harness, an explorer relay, and a web dashboard, all on an isolated network with a tuned Tor sidecar. The dashboard monitors sync health, peers, difficulty, and block stats.

**What you should know.**
- **Stressnet coins are not real XMR.** Mine them in-app, spam them, break things.
- First sync is slow by design: a full chain over Tor. Steady-state tip-following is fine; initial catch-up is a patience game. The dashboard's Sync Health panel tells you honestly where you stand.
- The low anonymity set on a testnet is exactly why Tor routing matters here.
- The wallet lab includes rescan tools and a faucet-by-mining flow. It's the fastest way to touch FCMP++ before mainnet.

---

## Privacy and security model (suite-wide)

- Local-first: chain data comes from **your** node. Nothing queries a third-party explorer by default.
- Tor where it matters: Superbrain's observer lookups and Superstress' entire network path. SuperPay can be reached as an onion when Umbrel's Tor is on.
- Least privilege inside the box: no app holds the raw Docker socket (Superbrain and Superstress use scoped control paths), secrets are owner-only files, and dashboards sit behind Umbrel's login.
- Pinned images, explicit versions, and multi-arch builds. No silent upstream changes.
- The weak points are the honest ones: an ASB holding liquidity is a server holding liquidity, testnets are testnets, and every payout address is only as safe as the key behind it.

## Data, backups and updates

- App data lives under `/home/umbrel/umbrel/app-data/<app>/`: wallets, databases, configs, logs.
- Umbrel reinstalls and app updates keep app data. Deleting an app in the UI **removes** it, so know your backup story first.
- SuperAtomic: use the built-in encrypted backup. SuperPay: your external wallet's seed is the backstop for funds.
- If your box runs an ASB with meaningful liquidity, back up the whole box. An off-box tarball of `app-data` is enough to recover.

## Hardware notes

- A modern 64-bit mini-PC (N100 class or better) runs the suite comfortably.
- Superbrain mining is CPU load. Superstress wants disk and patience. SuperAtomic is negligible CPU but wants uptime. SuperPay is trivial.
- Tailscale on your Umbrel and devices makes everything reachable safely from anywhere.

## Troubleshooting and support

- Update the app first. Most fixes are in release notes, and they're written for humans.
- Umbrel app logs are visible from the app's page (⋮ → Logs) or with `docker logs` over SSH.
- Issues: [github.com/brainchainz/Monero-Superbrain/issues](https://github.com/brainchainz/Monero-Superbrain/issues). Include app version, Umbrel version, and what you saw.

## Source, licenses and build pipeline

- Store and packaging: [github.com/brainchainz/Monero-Superbrain](https://github.com/brainchainz/Monero-Superbrain).
- Monero SuperAtomic's swap engine is a GPLv3 fork of eigenwallet/core. The complete corresponding source, patches, and the CI workflow that builds the exact binaries live at [github.com/brainchainz/eigenwallet-core](https://github.com/brainchainz/eigenwallet-core). The engine image is public on `ghcr.io/brainchainz/asb` (multi-arch, digest-pinned), built by the repo's dispatch-only workflow.
- App images are public Docker Hub (`sirjamzalot/*`) with explicit tags and digests where it matters.
- Each app's repo is linked from its store entry.

---

*Beta. Feedback welcome. Built by SirJamzAlot ([@MgkMshrmBrkfst](https://x.com/MgkMshrmBrkfst)).*
