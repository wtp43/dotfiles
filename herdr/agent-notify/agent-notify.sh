#!/usr/bin/env bash
# Notify when an agent finishes or needs input (see herdr-plugin.toml).
# Usage: agent-notify.sh event    - event hook: notify (macOS) or log (remote)
#        agent-notify.sh startup  - macOS: start the listener for saved machines
#        agent-notify.sh listen   - macOS: follow each saved machine's log over ssh
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/wt.agent-notify}
mkdir -p "$state_dir"
pidfile=$state_dir/listen.pid
# Remote machines write here; the Mac's listener reads it at this same path.
remote_log='.local/state/herdr/plugins/wt.agent-notify/events.log'

# post <machine label or ""> <JSON event line>: an agent event, or a "notice"
# with its own title and body (tmux-herdr-claude's herdr-claude writes those).
post() {
  local title subtitle body
  title=$(jq -r 'if .notice then .notice.title else "\(.agent // "agent" | ascii_upcase[0:1] + .[1:]) \(if .status == "blocked" then "needs input" else "finished" end)" end' <<<"$2")
  subtitle=$(jq -r --arg m "$1" '[$m, .workspace] | map(select(. != "" and . != null)) | join(" · ")' <<<"$2")
  body=$(jq -r '.notice.body // .title // ""' <<<"$2")
  if command -v terminal-notifier >/dev/null; then
    terminal-notifier -title "$title" -subtitle "$subtitle" -message "${body:- }" -sound default >/dev/null
  else
    osascript -e 'on run argv' \
      -e 'display notification (item 3 of argv) with title (item 1 of argv) subtitle (item 2 of argv) sound name "Glass"' \
      -e 'end run' "$title" "$subtitle" "$body" >/dev/null
  fi
}

listener_running() {
  local pid
  pid=$(cat "$pidfile" 2>/dev/null) && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

start_listener() {
  [ "$(uname)" = Darwin ] && ! listener_running || return 0
  # Detach fully: herdr waits on a hook's stdout/stderr until they close.
  nohup bash "$0" listen </dev/null >/dev/null 2>&1 &
  echo $! >"$pidfile"
}

# follow <label> <ssh target>: reconnect after sleep, network or ssh failures.
follow() {
  while "$herdr" status server >/dev/null 2>&1; do
    ssh -T -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 "$2" \
      "f=\$HOME/$remote_log; mkdir -p \"\${f%/*}\"; touch \"\$f\"; exec tail -n0 -F \"\$f\" 2>/dev/null" |
      while IFS= read -r line; do post "$1" "$line"; done
    sleep 10
  done
}

case $1 in
  startup) start_listener ;;
  event)
    event=$(jq -c '[.. | objects | select(has("agent_status"))][0] // empty' <<<"${HERDR_PLUGIN_EVENT_JSON:-}")
    [ -n "$event" ] || exit 0
    pane=$(jq -r .pane_id <<<"$event")
    status=$(jq -r .agent_status <<<"$event")
    # One notification per change into finished or blocked, not per repeat.
    last=$state_dir/last-$(tr ':/' '__' <<<"$pane")
    [ "$(cat "$last" 2>/dev/null)" = "$status" ] && exit 0
    echo "$status" >"$last"
    case $status in done|blocked) ;; *) exit 0 ;; esac

    workspace=$("$herdr" workspace get "$(jq -r .workspace_id <<<"$event")" 2>/dev/null | jq -r '.result.workspace.label // empty')
    line=$(jq -c --arg ws "$workspace" '{status: .agent_status, agent: (.display_agent // .agent), workspace: $ws, title}' <<<"$event")
    if [ "$(uname)" = Darwin ]; then
      post "" "$line"
      start_listener
    else
      log=$HOME/$remote_log
      # Followers use tail -F, which picks up the truncation.
      [ "$(wc -c <"$log" 2>/dev/null || echo 0)" -gt 100000 ] && : >"$log"
      echo "$line" >>"$log"
    fi ;;
  listen)
    trap 'kill $(jobs -p) 2>/dev/null' EXIT
    while IFS=$'\t' read -r label target; do
      follow "$label" "$target" &
    done < <("$herdr" machine list --json 2>/dev/null | jq -r '.[] | select(.enabled) | [.label, .target] | @tsv')
    wait ;;
esac
exit 0
