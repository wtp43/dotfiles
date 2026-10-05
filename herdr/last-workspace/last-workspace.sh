#!/usr/bin/env bash
# Keep the workspaces in most-recently-focused order (see herdr-plugin.toml).
# Usage: last-workspace.sh record - event hook: note the newly focused workspace
#        last-workspace.sh back   - action: focus the most recent other workspace
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-last-workspace}
mkdir -p "$state_dir"
mru=$state_dir/mru

snapshot=$("$herdr" api snapshot 2>/dev/null) || exit 0
focused=$(jq -r '.result.snapshot.focused_workspace_id // empty' <<<"$snapshot")
[ -n "$focused" ] || exit 0

# Move the focused workspace to the front. Closing a workspace moves focus
# without a workspace.focused event, so back records first too.
{ echo "$focused"; grep -vxF "$focused" "$mru" 2>/dev/null | head -n 30; } >"$mru.$$"
mv "$mru.$$" "$mru"

case $1 in
  back)
    # The first entry after the focused one that still exists.
    target=$(jq -r --rawfile mru "$mru" '
      [.result.snapshot.workspaces[].workspace_id] as $open
      | $mru | split("\n") | .[1:] | map(select(. as $id | $open | index($id))) | first // empty
      ' <<<"$snapshot")
    [ -n "$target" ] && "$herdr" workspace focus "$target" >/dev/null ;;
esac
exit 0
