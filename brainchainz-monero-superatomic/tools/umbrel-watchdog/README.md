# SuperAtomic onion watchdog (umbrel host)

Auto-heal for the asb's Tor onion service. The asb's embedded arti client
occasionally gets stuck in a `Bootstrapping` loop (visible on the app's network
page as "Tor onion — Starting"), typically after long periods of heavy host
load. While stuck, inbound connections over the onion service are unreliable
(takers may fail to connect).

This watchdog polls the asb's authenticated RPC from the host and restarts the
asb (via supervisor inside the container) when the onion service stays
unreachable for `THRESH` consecutive checks. It also keeps `xmrig` at
`nice 19` so latency-sensitive tor circuit building gets CPU priority.

## Files

- `superatomic-onion-watchdog.sh` — the poller (install to `/usr/local/bin/`, root)
- `superatomic-onion-watch.service` — oneshot unit that runs the poller
- `superatomic-onion-watch.timer` — systemd timer, fires every 60s

State: `/var/lib/superatomic-watchdog/` (strike counter, last-restart time)
Log:   `/var/log/superatomic-watchdog.log`

## Tunables (top of the script)

- `THRESH=12`    consecutive bad checks (60s each) before a restart
- `COOLDOWN=1500` minimum seconds between restarts
- `GRACE=360`    no strike counting during the first N seconds after a restart

## Install on the umbrel host (as root)

```sh
install -m0755 superatomic-onion-watchdog.sh /usr/local/bin/superatomic-onion-watchdog.sh
install -m0644 superatomic-onion-watch.service /etc/systemd/system/
install -m0644 superatomic-onion-watch.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now superatomic-onion-watch.timer
```

## Notes

- Restart action: `docker exec <app>_server supervisorctl restart asb`
  (falls back to `docker restart`). A restarted asb resumes swaps normally
  from its database.
- If the asb is mid-swap, a restart is safe: swap state is persisted and
  resumed on boot.
- Longer-term this should ship inside the app itself (exports.sh can install
  this timer on every host), and the arti pool/intro-point tuning lives in
  `exports.sh` / the fork pin.
