#!/usr/bin/env bash
# Label each tab "<state> [<number>] <title>" from its agents' state and the
# terminal title of the pane focused in it (see herdr-plugin.toml).
# Usage: tab-titles.sh sync   - relabel now, and start the poller if needed
#        tab-titles.sh loop   - poller for title changes, which have no hook
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-tab-titles}
mkdir -p "$state_dir"
pidfile=$state_dir/loop.pid
interval=2
max_title=30

relabel() {
  local snapshot tab label
  snapshot=$("$herdr" api snapshot 2>/dev/null) && [ -n "$snapshot" ] || return 1
  jq -r --argjson max "$max_title" '
    .result.snapshot as $s
    | ($s.panes | map({key: .pane_id, value: (.terminal_title_stripped // "")})
       | from_entries) as $titles
    | (reduce $s.tabs[] as $t ({}; .[$t.workspace_id] += [$t.tab_id])) as $order
    | (reduce $s.agents[] as $a ({}; .[$a.tab_id] += [$a.agent_status])) as $states
    | $s.layouts[] as $l
    | ($s.tabs[] | select(.tab_id == $l.tab_id)) as $t
    | ($order[$t.workspace_id] | index($t.tab_id) + 1) as $pos
    | ($titles[$l.focused_pane_id] // "") as $title
    | (if ($title | length) > $max then $title[0:$max - 1] + "…" else $title end) as $title
    # The most urgent agent state in the tab, drawn as herdr symbols style does.
    | ($states[$t.tab_id] // []) as $st
    | (if ($st | index("blocked")) then "× "
       elif ($st | index("working")) then "◐ "
       elif ($st | index("done")) then "✓ "
       elif ($st | index("idle")) then "○ "
       else "" end) as $icon
    | ("\($icon)[\($pos)]" + (if $title == "" then "" else " \($title)" end)) as $want
    | select($want != $t.label)
    | [$t.tab_id, $want] | @tsv' <<<"$snapshot" |
    while IFS=$'\t' read -r tab label; do
      "$herdr" tab rename "$tab" "$label" >/dev/null
    done
}

loop_running() {
  local pid
  pid=$(cat "$pidfile" 2>/dev/null) && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

case $1 in
  sync)
    relabel
    if ! loop_running; then
      # Detach fully: herdr waits on a hook's stdout/stderr until they close.
      nohup bash "$0" loop </dev/null >/dev/null 2>&1 &
      echo $! >"$pidfile"
    fi ;;
  loop)
    # Exits with the server, since the snapshot request then fails.
    while relabel; do sleep "$interval"; done
    rm -f "$pidfile" ;;
esac
exit 0
