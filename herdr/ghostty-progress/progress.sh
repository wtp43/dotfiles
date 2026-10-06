#!/usr/bin/env bash
# Ghostty progress bar for herdr agents (see herdr-plugin.toml).
# Usage: progress.sh sync   - update now, and start the refresher if needed
#        progress.sh loop   - refresher: re-send while working, since Ghostty
#                             drops a progress bar that stops being refreshed
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-ghostty-progress}
mkdir -p "$state_dir"
pidfile=$state_dir/loop.pid
lastfile=$state_dir/last
interval=3

# "working" if an agent in the focused tab is working, else "idle".
agent_state() {
  "$herdr" api snapshot 2>/dev/null | jq -r '.result.snapshot as $s
    | if any($s.panes[]; .tab_id == $s.focused_tab_id and .agent_status == "working")
      then "working" else "idle" end'
}

# Ttys of herdr clients attached to an outer terminal: herdr processes with a
# tty that do not descend from a herdr server (those are panes running the CLI).
client_ttys() {
  local servers pid tty p
  servers=" $(pgrep -f 'herdr server' | tr '\n' ' ') "
  for pid in $(pgrep -x herdr); do
    [[ $servers == *" $pid "* ]] && continue
    tty=$(ps -o tty= -p "$pid" | tr -d ' ')
    [[ -n $tty && $tty != "??" ]] || continue
    p=$pid
    while [[ -n $p && $p -gt 1 ]]; do
      [[ $servers == *" $p "* ]] && continue 2
      p=$(ps -o ppid= -p "$p" | tr -d ' ')
    done
    echo "/dev/$tty"
  done | sort -u
}

# OSC 9;4: 3 = indeterminate (the animated bar), 0 = clear.
emit() {
  local seq tty
  seq=$(printf '\033]9;4;%s\007' "$1")
  for tty in $(client_ttys); do
    [ -w "$tty" ] && printf '%s' "$seq" >"$tty"
  done
}

# Emit for the current state; "force" re-sends an unchanged working state.
update() {
  local now last
  now=$(agent_state)
  [ -n "$now" ] || return 1
  last=$(cat "$lastfile" 2>/dev/null)
  if [ "$now" = working ]; then
    { [ "$last" != working ] || [ "$1" = force ]; } && emit 3
  elif [ "$last" = working ]; then
    emit 0
  fi
  echo "$now" >"$lastfile"
}

loop_running() {
  local pid
  pid=$(cat "$pidfile" 2>/dev/null) && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

case $1 in
  sync)
    update
    if ! loop_running; then
      # Detach fully: herdr waits on a hook's stdout/stderr until they close.
      nohup bash "$0" loop </dev/null >/dev/null 2>&1 &
      echo $! >"$pidfile"
    fi ;;
  loop)
    # Exits with the server, since the snapshot request then fails.
    while update force; do sleep "$interval"; done
    rm -f "$pidfile" ;;
esac
exit 0
