# Sourced by the plugin's scripts: finds herdr and answers questions about its
# panes from `herdr api snapshot`.
PATH=$HOME/.local/bin:$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
# bin/resume-hook leaves <terminal> -> <terminal> here for bin/attach-terminal.
redirects=${XDG_STATE_HOME:-$HOME/.local/state}/tmux-herdr-claude/redirect

snapshot() { "$herdr" api snapshot 2>/dev/null; }

# pane_of <terminal_id>
pane_of() {
  snapshot | jq -r --arg t "$1" '.result.snapshot.panes[] | select(.terminal_id == $t) | .pane_id'
}

# terminal_of <pane_id>
terminal_of() {
  snapshot | jq -r --arg p "$1" '.result.snapshot.panes[] | select(.pane_id == $p) | .terminal_id'
}

# session_terminal <claude_session_id> [pane_id to skip]: the terminal already running it.
session_terminal() {
  snapshot | jq -r --arg s "$1" --arg skip "${2:-}" '
    first(.result.snapshot.panes[] | select(.agent_session.value == $s and .pane_id != $skip)) | .terminal_id'
}
