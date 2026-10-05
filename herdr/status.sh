#!/usr/bin/env bash
# Tab bar status entries (tab_bar_right in config.toml), ported from the tmux
# status line. Herdr strips colors, so tmux #[...] styles are removed.
# Usage: status.sh host|local|workspace|remote
PATH=$PATH:/opt/homebrew/bin
export LC_ALL=en_US.UTF-8
herdr=${HERDR_BIN_PATH:-herdr}
pane=$HERDR_ACTIVE_PANE_ID

plain() { sed 's/#\[[^]]*\]//g'; }

# ssh/mosh command line in the focused pane, if any.
ssh_cmd() {
  [ -n "$pane" ] || return
  "$herdr" pane process-info --pane "$pane" | jq -r '
    .result.process_info.foreground_processes[]
    | select(.argv0 | test("^(.*/)?(ssh|autossh|mosh[^/]*)$")) | .cmdline' | head -1
}

# The ssh alias (e.g. "dev") the command connects to, like tmux/pane-host.sh.
ssh_host() {
  local h= w
  case $1 in
    ssh\ *|autossh\ *)
      h=$(ssh -G ${1#* } 2>/dev/null </dev/null | awk '$1 == "host" {print $2; exit}') ;;
    mosh*)
      for w in ${1#* }; do [[ $w == -* ]] || h=$w; done
      h=${h#*@} ;;
  esac
  echo "$h"
}

case $1 in
  host)
    h=$(ssh_host "$(ssh_cmd)")
    echo "󰙴 󰆦 ${h:-$(hostname -s)} $(date +%-I:%M%p)" ;;
  workspace)
    "$herdr" workspace get "$HERDR_ACTIVE_WORKSPACE_ID" | jq -r '.result.workspace.label // empty' ;;
  remote)
    h=$(ssh_host "$(ssh_cmd)")
    [ -n "$h" ] && [ "$h" != "$(hostname -s)" ] || exit 0
    # A shared master connection; a fresh handshake every interval is slow.
    out=$(ssh -o BatchMode=yes -o ConnectTimeout=2 \
      -o ControlMaster=auto -o ControlPath="$HOME/.ssh/cm-%C" -o ControlPersist=60 \
      "$h" 'uname -n | cut -d. -f1; sh -s 2' < ~/.config/tmux/mem-cpu.sh 2>/dev/null)
    name=$(sed -n 1p <<<"$out")
    stats=$(sed -n 2p <<<"$out" | plain)
    [ -n "$stats" ] && echo "[$name $stats]" ;;
  local)
    ~/.config/tmux/mem-cpu.sh 2 | plain ;;
esac
