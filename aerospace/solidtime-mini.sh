#!/bin/bash
# Pin the Solidtime Mini-Tracker to the top-right corner of the 'work' workspace.
# AeroSpace can't position floating windows, and macOS only makes a position stick
# while that window's workspace is visible, so we (re)apply the top-right position
# whenever 'work' becomes focused. Runs on workspace change and at launch.
[ "$(aerospace list-workspaces --focused 2>/dev/null)" = "work" ] || exit 0

LOCK=/tmp/solidtime-mini.lock
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

# The Mini-Tracker is the floating Solidtime window (resize can't touch floating).
mini=""
for id in $(aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
             | awk -F'|' '$2=="io.solidtime.desktop"{print $1}'); do
  aerospace resize width +0 --window-id "$id" 2>&1 | grep -qi floating && { mini="$id"; break; }
done
[ -n "$mini" ] || exit 0

aerospace move-node-to-workspace work --window-id "$mini" 2>/dev/null

# Top-right corner, relative to the screen and the window's own width.
osascript <<'EOF' 2>/dev/null
set margin to 6
tell application "Finder" to set scrn to bounds of window of desktop
set scrRight to item 3 of scrn
set scrTop to item 2 of scrn
tell application "System Events" to tell process "solidtime"
  repeat with w in windows
    set s to size of w
    if (item 2 of s) < 100 then
      set position of w to {scrRight - (item 1 of s) - margin, scrTop + margin}
      exit repeat
    end if
  end repeat
end tell
EOF
