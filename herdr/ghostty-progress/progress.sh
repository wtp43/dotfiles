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
interval=3

# "<tty> <terminal id or ->" per herdr client attached to an outer terminal:
# herdr processes with a tty that do not descend from a herdr server (those are
# panes running the CLI). A direct attach (`herdr terminal attach <id>`, as
# tmux-herdr-claude uses) shows one terminal; a herdr window shows the focused
# tab, which a direct attach never changes.
clients() {
  local servers pid tty p args
  servers=" $(pgrep -f 'herdr server' | tr '\n' ' ') "
  for pid in $(pgrep -x herdr); do
    [[ $servers == *" $pid "* ]] && continue
    tty=$(ps -o tty= -p "$pid" | tr -d ' ')
    [[ -n $tty && $tty != "??" && $tty != "?" ]] || continue
    p=$pid
    while [[ -n $p && $p -gt 1 ]]; do
      [[ $servers == *" $p "* ]] && continue 2
      p=$(ps -o ppid= -p "$p" | tr -d ' ')
    done
    args=$(ps -o args= -p "$pid")
    [[ $args =~ terminal\ attach\ ([^ ]+) ]] && echo "/dev/$tty ${BASH_REMATCH[1]}" || echo "/dev/$tty -"
  done | sort -u
}

# OSC 9;4: 3 = indeterminate (the animated bar), 0 = clear.
emit() {
  [ -w "$1" ] && printf '\033]9;4;%s\007' "$2" >"$1"
}

# Emit each client's current state; "force" re-sends an unchanged working state.
update() {
  local snapshot tty terminal now last lastfile
  snapshot=$("$herdr" api snapshot 2>/dev/null) && [ -n "$snapshot" ] || return 1
  while read -r tty terminal; do
    [ -n "$tty" ] || continue
    now=$(jq -r --arg t "$terminal" '.result.snapshot as $s
      | [$s.panes[] | select(if $t == "-" then .tab_id == $s.focused_tab_id else .terminal_id == $t end)]
      | if any(.[]; .agent_status == "working") then "working" else "idle" end' <<<"$snapshot")
    lastfile=$state_dir/last-$(tr / _ <<<"${tty#/dev/}")
    last=$(cat "$lastfile" 2>/dev/null)
    if [ "$now" = working ]; then
      { [ "$last" != working ] || [ "$1" = force ]; } && emit "$tty" 3
    elif [ "$last" = working ]; then
      emit "$tty" 0
    fi
    echo "$now" >"$lastfile"
  done < <(clients)
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
