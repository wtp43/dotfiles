#!/usr/bin/env bash
# Split the focused pane toward $1 (left|down|up|right), keeping its cwd.
# If the pane is running ssh/mosh, the new pane opens the same connection.
# Herdr does not expose OSC 7, so ssh panes open in the remote home dir.
# Herdr only splits right/down; left/up split, then swap the new pane over.
dir=$1
src=$HERDR_ACTIVE_PANE_ID
[ -n "$src" ] || exit 1
herdr=${HERDR_BIN_PATH:-herdr}
PATH=$PATH:/opt/homebrew/bin  # jq, if the server started without a login PATH

cmd=$("$herdr" pane process-info --pane "$src" | jq -r '
  .result.process_info.foreground_processes[]
  | select((.argv0 // "") | test("^(.*/)?(ssh|autossh|mosh[^/]*)$")) | .cmdline' | head -1)

case $dir in
  left|right) split=right ;;
  up|down) split=down ;;
  *) exit 2 ;;
esac
cwd=${HERDR_ACTIVE_PANE_CWD:+--cwd "$HERDR_ACTIVE_PANE_CWD"}
new=$("$herdr" pane split --pane "$src" --direction "$split" $cwd --focus |
  jq -r .result.pane.pane_id)
[ -n "$new" ] && [ "$new" != null ] || exit 1

case $dir in
  left) "$herdr" pane swap --pane "$new" --direction left >/dev/null ;;
  up) "$herdr" pane swap --pane "$new" --direction up >/dev/null ;;
esac
[ -n "$cmd" ] && "$herdr" pane run "$new" "$cmd" >/dev/null
exit 0
