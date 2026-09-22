#!/bin/bash
# On solidtime launch (WITHOUT stealing focus):
#   - main window  -> workspace 'org', pinned to 813px wide (width only)
#   - Mini-Tracker -> workspace 'work', top-right corner (see solidtime-mini.sh)
# Runs once per launch (mkdir lock guards the double on-window-detected fire).
LOCK=/tmp/solidtime-aero.lock
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

orig=$(aerospace list-workspaces --focused 2>/dev/null)
DIR="$(cd "$(dirname "$0")" && pwd)"

st_ids() {
  aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
    | awk -F'|' '$2=="io.solidtime.desktop"{print $1}'
}

# Wait for both windows to exist and settle.
for _ in $(seq 1 40); do
  [ "$(st_ids | wc -l | tr -d ' ')" -ge 2 ] && break
  sleep 0.25
done
sleep 0.6

# Route: Mini-Tracker (floating) -> work; main (tiled) -> org.
main_id=""
for id in $(st_ids); do
  if aerospace resize width +0 --window-id "$id" 2>&1 | grep -qi floating; then
    aerospace move-node-to-workspace work --window-id "$id" 2>/dev/null
  else
    main_id="$id"
    aerospace move-node-to-workspace org --window-id "$id" 2>/dev/null
  fi
done

# Pin main to 813px. AeroSpace only resizes the FOCUSED window's workspace, so
# focus the main directly (this activates 'org'), flatten, resize, then return
# the user. A second resize re-asserts against any settle race.
if [ -n "$main_id" ]; then
  aerospace focus --window-id "$main_id" 2>/dev/null
  aerospace flatten-workspace-tree --workspace org 2>/dev/null
  aerospace resize width 813 --window-id "$main_id" 2>/dev/null
  sleep 0.2
  aerospace resize width 813 --window-id "$main_id" 2>/dev/null
fi

# Return the user to their workspace as the last action. The workspace-change
# callback (exec-on-workspace-change -> solidtime-mini.sh) positions the mini
# top-right when 'work' becomes visible.
[ -n "$orig" ] && aerospace workspace "$orig" 2>/dev/null
