#!/usr/bin/env bash
# vim-tmux-navigator for herdr: ctrl+h/j/k/l ($2) goes to (n)vim when it is the
# focused pane's foreground program, else herdr moves focus toward $1.
# nvim hands focus back to herdr at its edge (nvim/lua/plugins/vim-tmux-navigator.lua).
dir=$1 key=$2
pane=$HERDR_ACTIVE_PANE_ID
[ -n "$pane" ] || exit 1
herdr=${HERDR_BIN_PATH:-herdr}
PATH=$PATH:/opt/homebrew/bin  # jq, if the server started without a login PATH

if "$herdr" pane process-info --pane "$pane" | jq -e '
  any(.result.process_info.foreground_processes[];
      .argv0 | test("^(.*/)?(g?view|l?n?vim?x?|fzf)(diff)?$"))' >/dev/null; then
  exec "$herdr" pane send-keys "$pane" "$key" >/dev/null
fi
exec "$herdr" pane focus --pane "$pane" --direction "$dir" >/dev/null
