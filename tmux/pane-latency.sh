#!/usr/bin/env bash
# Round-trip time to the host an ssh/et pane is connected to; "relay" when
# Tailscale is going through DERP instead of a direct path. Each sample is
# appended to ~/Library/Logs/pane-latency.log for diagnosing lag after the fact.
# Usage: pane-latency.sh <pane_id> <pane_pid>
host=$(~/.config/tmux/pane-host.sh "$1" "$2")
[ "$host" = "$(hostname -s)" ] && exit 0
addr=$(ssh -G "$host" 2>/dev/null </dev/null | awk '$1 == "hostname" {print $2; exit}')
[ -n "$addr" ] || exit 0

ts=/Applications/Tailscale.app/Contents/MacOS/Tailscale
path= ms=
if [[ $addr == 100.* ]] && [ -x "$ts" ]; then
  # "pong from cachyos (100.x) via 192.168.50.60:41641 in 4ms" or "via DERP(sea) in 40ms"
  out=$("$ts" ping -c 1 --timeout 2s "$addr" 2>/dev/null)
  if [[ $out =~ via\ ([^ ]+)\ in\ ([0-9.]+)ms ]]; then
    ms=${BASH_REMATCH[2]%.*}
    [[ ${BASH_REMATCH[1]} =~ DERP|relay ]] && path=relay || path=direct
  fi
else
  out=$(ping -c 1 -t 2 "$addr" 2>/dev/null)
  [[ $out =~ time=([0-9.]+)\ ms ]] && ms=${BASH_REMATCH[1]%.*} path=icmp
fi

log=~/Library/Logs/pane-latency.log
echo "$(date '+%F %T') $host ${ms:-timeout} ${path:--}" >>"$log"
[ "$(stat -f %z "$log")" -gt 5000000 ] && tail -n 20000 "$log" >"$log.tmp" && mv "$log.tmp" "$log"

if [ -z "$ms" ]; then
  echo "#[fg=red]timeout#[default] "
  exit 0
fi
if [ "$ms" -ge 100 ]; then col=red
elif [ "$ms" -ge 50 ]; then col=colour208
elif [ "$ms" -ge 20 ]; then col=#14b8a6
else col=green
fi
suffix=
[ "$path" = relay ] && col=red suffix=" relay"
echo "#[fg=$col]${ms}ms$suffix#[default] "
