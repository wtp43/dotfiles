#!/usr/bin/env bash
# Print the host a pane's ssh/mosh session is connected to (the ssh alias,
# e.g. "dev"); falls back to the local short hostname.
# Usage: pane-host.sh <pane_id> <pane_pid>
pane=$1 pid=$2
# Panes opened by split-same.sh carry their ssh command in @ssh_cmd.
cmd=$(tmux show -pqv -t "$pane" @ssh_cmd)
if [ -z "$cmd" ]; then
  for c in $(pgrep -P "$pid"); do
    args=$(ps -o args= -p "$c")
    if [[ $args =~ ^(ssh|mosh|autossh)( |$) ]]; then cmd=$args; break; fi
  done
fi
host=
case $cmd in
  ssh\ *|autossh\ *)
    # ssh -G resolves options and config aliases; its "host" line is the alias.
    host=$(ssh -G ${cmd#* } 2>/dev/null </dev/null | awk '$1 == "host" {print $2; exit}') ;;
  mosh\ *)
    # Last non-option word is the destination ([user@]host); good enough for mosh.
    for w in ${cmd#* }; do [[ $w == -* ]] || host=$w; done
    host=${host#*@} ;;
esac
echo "${host:-$(hostname -s)}"
