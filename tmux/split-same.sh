#!/usr/bin/env bash
# Split a pane; if it runs ssh/mosh, the new pane opens the same connection,
# in the remote cwd when the remote shell reports it (OSC 7 -> #{pane_path}).
# pgrep -P + ps -p instead of ps --ppid, which BSD/macOS ps lacks.
pane=$1 pid=$2 path=$3 osc7=$4; shift 4
# Panes this script opened run ssh as the pane process with our cd appended,
# so their child scan finds nothing; they carry the original command instead.
cmd=$(tmux show -pqv -t "$pane" @ssh_cmd)
if [ -z "$cmd" ]; then
  for c in $(pgrep -P "$pid"); do
    args=$(ps -o args= -p "$c")
    if [[ $args =~ ^(ssh|mosh|autossh)( |$) ]]; then cmd=$args; break; fi
  done
fi
if [ -z "$cmd" ]; then
  exec tmux split-window -t "$pane" "$@" -c "$path"
fi
base=$cmd
# Assumes the ssh line has no remote command of its own; one would take ours
# as extra arguments.
if [[ $cmd =~ ^ssh( |$) && $osc7 == file://* ]]; then
  dir=/${osc7#file://*/}
  dir=$(printf '%b' "${dir//%/\\x}")
  remote="cd $(printf '%q' "$dir") 2>/dev/null; exec \$SHELL -l"
  cmd="ssh -t ${cmd#ssh } $(printf '%q' "$remote")"
fi
new=$(tmux split-window -P -F '#{pane_id}' -t "$pane" "$@" -c "$path" \
  "$cmd; tmux set -pu -t \"\$TMUX_PANE\" @ssh_cmd; exec \$SHELL -l") &&
  tmux set -p -t "$new" @ssh_cmd "$base"
