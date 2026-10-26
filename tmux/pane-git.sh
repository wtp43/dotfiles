#!/usr/bin/env bash
# Git branch of the active pane's cwd as " ∣ [branch +dirty]", styled like the
# Claude Code status line. An et pane's cwd comes from its tmux session on the
# host (the nested tmux doesn't forward OSC 7); an ssh pane's from OSC 7.
# Usage: pane-git.sh <pane_id> <pane_pid> <pane_current_path> <pane_path> <pane_current_command>
pane=$1 pid=$2 cwd=$3 osc7=$4 cur=$5
probe='b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) && echo "$b $(git status --porcelain 2>/dev/null | wc -l)"'

if [[ $cur =~ ^(ssh|autossh|et)$ ]]; then
  host=$(~/.config/tmux/pane-host.sh "$pane" "$pid")
  [ "$host" = "$(hostname -s)" ] && exit 0
  cmd=
  for c in $(pgrep -P "$pid"); do
    args=$(ps -o args= -p "$c")
    if [[ $args =~ ^(ssh|autossh)( |$)|(^|[ /])etd( |$) ]]; then cmd=$args; break; fi
  done
  [ -n "$cmd" ] || cmd=$(tmux show -pqv -t "$pane" @ssh_cmd)
  etd_re='(^|[ /])etd ([^ ]+) ([^ ]+)'
  if [[ $cmd =~ $etd_re ]]; then
    dir="\"\$(tmux display -p -t $(printf '%q' "${BASH_REMATCH[3]}") '#{pane_current_path}')\""
  elif [[ $osc7 == file://* && ${osc7#file://} != "$(hostname -s)"/* ]]; then
    dir=/${osc7#file://*/}
    dir=$(printf '%q' "$(printf '%b' "${dir//%/\\x}")")
  else
    exit 0
  fi
  out=$(ssh -o BatchMode=yes -o ConnectTimeout=2 \
    -o ControlMaster=auto -o ControlPath="$HOME/.ssh/cm-%C" -o ControlPersist=60 \
    "$host" "cd $dir 2>/dev/null && $probe" </dev/null 2>/dev/null)
else
  out=$(cd "$cwd" 2>/dev/null && eval "$probe")
fi

read -r branch dirty <<<"$out"
[ -n "$branch" ] || exit 0
branch=${branch//#/##}
seg="#[fg=yellow]$branch#[default]"
[ "${dirty:-0}" -gt 0 ] && seg="$seg +$dirty"
echo " ∣ #[fg=brightblack][#[default]$seg#[fg=brightblack]]#[default]"
