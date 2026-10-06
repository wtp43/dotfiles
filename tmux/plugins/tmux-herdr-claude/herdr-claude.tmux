#!/usr/bin/env bash
# tmux-herdr-claude: `claude` typed in tmux runs in a background herdr tab and is
# attached to the tmux pane, so herdr (and Heeler) can see and manage it.
#
# Load:   run-shell ~/.config/tmux/plugins/tmux-herdr-claude/herdr-claude.tmux
# Revert: delete that tmux.conf line, then `tmux set-environment -gu LC_HERDR_CLAUDE`
#         and `tmux unbind -n C-v` (or restart tmux); claude then runs directly.
#
# The switch is an LC_* variable so `ssh` carries it to machines that accept it
# (AcceptEnv LC_HERDR_CLAUDE), where the same zsh hook uses that machine's herdr.
# shell/herdr-claude.zsh, sourced from zshrc, reads it.
tmux set-environment -g LC_HERDR_CLAUDE 1

# ctrl+v in a pane connected over ssh pastes the Mac clipboard's image there.
tmux bind -n C-v run-shell -b "$(dirname "$0")/bin/paste-image '#{pane_id}' '#{pane_pid}'"
