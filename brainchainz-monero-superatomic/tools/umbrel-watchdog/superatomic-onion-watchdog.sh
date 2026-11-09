#!/bin/bash
# SuperAtomic onion auto-heal watchdog
#
# Polls the asb's onion_service_status via its authenticated RPC.
# If the onion stays non-Running/unreachable for THRESH consecutive checks,
# restart the asb process (via supervisor) so arti rebuilds fresh.
# Also keeps xmrig at nice 19 so latency-sensitive tor work gets CPU priority.
#
# Install: /usr/local/bin/superatomic-onion-watchdog.sh (root, 0755)
# Runs via superatomic-onion-watch.timer every 60s.
set -u

C=brainchainz_monero_superatomic_server
DATA=/home/umbrel/umbrel/app-data/brainchainz-monero-superatomic/data
ST=/var/lib/superatomic-watchdog
LOG=/var/log/superatomic-watchdog.log
THRESH=12              # consecutive bad checks (60s each) before a restart
COOLDOWN=1500          # min seconds between restarts
GRACE=360              # no strike counting during first N seconds after restart

mkdir -p "$ST" 2>/dev/null || true
now=$(date +%s)

# Keep the miner out of tor's way (idempotent, survives xmrig restarts)
for p in $(pgrep -x xmrig) $(pgrep -x xmrig-proxy); do
  ni=$(ps -o ni= -p "$p" 2>/dev/null | tr -d ' ')
  [ -n "$ni" ] && [ "$ni" != "19" ] && renice 19 -p "$p" >/dev/null 2>&1
done

last=$(cat "$ST/last_restart" 2>/dev/null || echo 0)

pw=$(tr -d '\n' < "$DATA/rpc-password" 2>/dev/null)
if [ -z "$pw" ]; then
  echo "$(date -u +%FT%TZ) WARN: cannot read rpc-password" >> "$LOG"
  exit 0
fi

resp=$(docker exec "$C" curl -s -m 10 --oauth2-bearer "$pw" \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"onion_service_status","params":[]}' \
  http://127.0.0.1:9944 2>/dev/null)

ok=0
case "$resp" in
  *'"reachable":true'*) ok=1 ;;
esac

# grace period after a restart (fresh bootstrap needs a few minutes)
if [ $((now - last)) -lt "$GRACE" ]; then exit 0; fi

strikes=$(cat "$ST/strikes" 2>/dev/null || echo 0)
if [ "$ok" = 1 ]; then
  if [ "$strikes" != "0" ]; then
    echo "$(date -u +%FT%TZ) onion recovered (was $strikes strikes)" >> "$LOG"
  fi
  echo 0 > "$ST/strikes"
  exit 0
fi

strikes=$((strikes + 1))
echo "$strikes" > "$ST/strikes"
echo "$(date -u +%FT%TZ) bad check $strikes/$THRESH: ${resp:-<no response>}" >> "$LOG"

if [ "$strikes" -ge "$THRESH" ] && [ $((now - last)) -ge "$COOLDOWN" ]; then
  echo "$(date -u +%FT%TZ) RESTARTING asb (stuck ${strikes} checks)" >> "$LOG"
  if ! docker exec "$C" supervisorctl restart asb >> "$LOG" 2>&1; then
    echo "$(date -u +%FT%TZ) supervisorctl failed; falling back to docker restart" >> "$LOG"
    docker restart "$C" >> "$LOG" 2>&1
  fi
  echo "$now" > "$ST/last_restart"
  echo 0 > "$ST/strikes"
fi
