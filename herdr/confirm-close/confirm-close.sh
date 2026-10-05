#!/usr/bin/env bash
# Close the focused pane or tab only on y (see herdr-plugin.toml).
# Usage: confirm-close.sh open pane|tab - action: open the popup
#        confirm-close.sh pane|tab      - popup: prompt, then close
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
context=${HERDR_PLUGIN_CONTEXT_JSON:-{\}}
case $1 in
  open) exec "$herdr" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint "$2" >/dev/null ;;
  pane) id=$(jq -r '.focused_pane_id // empty' <<<"$context"); filter='.result.pane.terminal_title_stripped' ;;
  tab) id=$(jq -r '.tab_id // empty' <<<"$context"); filter='.result.tab.label' ;;
  *) exit 1 ;;
esac
[ -n "$id" ] || exit 1
name=$("$herdr" "$1" get "$id" 2>/dev/null | jq -r "$filter // empty")
name=${name:-$id}

cols=$(tput cols 2>/dev/null || echo 56)
max=$((cols - 4))
if ((${#name} > max)); then
  # Paths keep their tail, tab labels their [number] head.
  if [ "$1" = pane ]; then name="…${name: -$((max - 1))}"; else name="${name:0:$((max - 1))}…"; fi
fi

accent=$'\e[1;38;2;90;191;181m' bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'
printf '\e]0;close %s\a\e[?25l' "$1"
trap 'printf "\e[?25h"' EXIT
printf '  %sClose this %s?%s\n  %s%s%s\n\n  %sy%s %sclose%s  ·  %sany key%s %scancel%s' \
  "$bold" "$1" "$reset" "$dim" "$name" "$reset" \
  "$accent" "$reset" "$bold" "$reset" "$dim" "$reset" "$dim" "$reset"
read -rsn1 answer
[[ $answer == [yY] ]] && "$herdr" "$1" close "$id" >/dev/null
exit 0
