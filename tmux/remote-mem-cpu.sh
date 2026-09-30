#!/bin/sh
# CPU/RAM of the host an ssh/mosh pane is connected to, via the local mem-cpu.sh.
# Usage: remote-mem-cpu.sh <pane_id> <pane_pid>
host=$(~/.config/tmux/pane-host.sh "$1" "$2")
[ "$host" = "$(hostname -s)" ] && exit 0
# A shared master connection; a fresh handshake every status-interval is slow.
out=$(ssh -o BatchMode=yes -o ConnectTimeout=2 \
  -o ControlMaster=auto -o ControlPath="$HOME/.ssh/cm-%C" -o ControlPersist=60 \
  "$host" 'uname -n | cut -d. -f1; sh -s 3' < ~/.config/tmux/mem-cpu.sh 2>/dev/null)
name=$(printf '%s\n' "$out" | sed -n 1p)
stats=$(printf '%s\n' "$out" | sed -n 2p)
[ -n "$stats" ] && echo "[#[fg=green]$name#[default] $stats] "
