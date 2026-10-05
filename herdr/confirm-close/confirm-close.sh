#!/usr/bin/env bash
# Close the focused pane or tab only on y (see herdr-plugin.toml).
# Usage: confirm-close.sh open pane|tab - action: turn the accent red, open the popup
#        confirm-close.sh pane|tab      - popup: prompt, restore the accent, close
#        confirm-close.sh recover       - event hook: restore after a killed popup
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
context=${HERDR_PLUGIN_CONTEXT_JSON:-{\}}
config=${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml
state=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}
saved=$state/accent
popup_pid=$state/popup.pid

# The focused pane border is drawn in the accent, and herdr has no per-pane
# border colour, so the config's accent is swapped and the server reloaded.
set_accent() {
  ACCENT=$1 perl -pi -e 's/^accent = "[^"]*"/accent = "$ENV{ACCENT}"/' "$config"
  "$herdr" server reload-config >/dev/null
}

warn_accent() {
  # Keep the first saved colour if a previous popup died before restoring.
  [ -f "$saved" ] || sed -n 's/^accent = "\([^"]*\)".*/\1/p' "$config" >"$saved"
  set_accent red
}

restore_accent() {
  [ -s "$saved" ] || return
  set_accent "$(cat "$saved")"
  rm -f "$saved"
}

popup_running() {
  local pid
  pid=$(cat "$popup_pid" 2>/dev/null) && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

case $1 in
  open)
    warn_accent
    "$herdr" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint "$2" >/dev/null || restore_accent
    exit 0 ;;
  recover)
    popup_running || restore_accent
    exit 0 ;;
  pane) id=$(jq -r '.focused_pane_id // empty' <<<"$context"); filter='.result.pane.terminal_title_stripped' ;;
  tab) id=$(jq -r '.tab_id // empty' <<<"$context"); filter='.result.tab.label' ;;
  *) exit 1 ;;
esac
echo $$ >"$popup_pid"
trap 'printf "\e[?25h"; restore_accent; rm -f "$popup_pid"' EXIT
[ -n "$id" ] || exit 1
name=$("$herdr" "$1" get "$id" 2>/dev/null | jq -r "$filter // empty")
name=${name:-$id}

cols=$(tput cols 2>/dev/null || echo 56)
max=$((cols - 4))
if ((${#name} > max)); then
  # Paths keep their tail, tab labels their [number] head.
  if [ "$1" = pane ]; then name="…${name: -$((max - 1))}"; else name="${name:0:$((max - 1))}…"; fi
fi

red=$'\e[1;31m' bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'
printf '\e]0;close %s\a\e[?25l' "$1"
printf '  %sClose this %s?%s\n  %s%s%s\n\n  %sy%s %sclose%s  ·  %sany key%s %scancel%s' \
  "$bold" "$1" "$reset" "$dim" "$name" "$reset" \
  "$red" "$reset" "$bold" "$reset" "$dim" "$reset" "$dim" "$reset"
read -rsn1 answer
# Restore first: closing a tab's last pane closes the tab, and herdr kills the
# popup with it before an exit trap could run.
restore_accent
[[ $answer == [yY] ]] && "$herdr" "$1" close "$id" >/dev/null
exit 0
