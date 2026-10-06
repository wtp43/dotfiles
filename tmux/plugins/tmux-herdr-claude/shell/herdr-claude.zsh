# Sourced from zshrc. claude runs in herdr while tmux-herdr-claude is loaded:
# in tmux, each prompt copies tmux's global LC_HERDR_CLAUDE into the shell, so
# loading or removing the plugin applies to panes that are already open (and
# ssh forwards the current value); over ssh, the forwarded value decides.

# A herdr tab made by bin/herdr-claude: become Claude Code before the first
# prompt. Unset first so shells that Claude Code starts don't do it again.
if [[ -n $HERDR_ENV && -n $HERDR_CLAUDE_EXEC ]]; then
  _herdr_claude_args=$HERDR_CLAUDE_ARGS
  # Started over ssh: Claude Code copies with shim/wl-copy, which it only
  # picks when a Wayland display is set.
  if [[ -n $HERDR_CLAUDE_REMOTE_CLIPBOARD ]]; then
    path=(${${(%):-%x}:A:h:h}/shim $path)
    export WAYLAND_DISPLAY=herdr-clipboard
  fi
  unset HERDR_CLAUDE_EXEC HERDR_CLAUDE_ARGS HERDR_CLAUDE_REMOTE_CLIPBOARD
  eval "exec claude $_herdr_claude_args"
fi

[[ -z $HERDR_ENV && ( -n $TMUX || -n $LC_HERDR_CLAUDE ) ]] || return 0

_herdr_claude_bin=${${(%):-%x}:A:h:h}/bin

if [[ -n $TMUX ]]; then
  _herdr_claude_sync() {
    if [[ $(tmux show-environment -g LC_HERDR_CLAUDE 2>/dev/null) == LC_HERDR_CLAUDE=1 ]]; then
      export LC_HERDR_CLAUDE=1
    else
      unset LC_HERDR_CLAUDE
    fi
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _herdr_claude_sync
  _herdr_claude_sync
fi

# zshrc's tmux alias would shadow claude(); keep it for when the plugin is off.
_herdr_claude_plain=${aliases[claude]:-command claude}
unalias claude 2>/dev/null

# Claude Code in a background herdr tab, attached here; `command claude` skips it.
claude() {
  if [[ -n $LC_HERDR_CLAUDE ]]; then
    "$_herdr_claude_bin/herdr-claude" "$@"
    # 75: herdr isn't running (herdr-claude posted a notification).
    local rc=$?
    (( rc == 75 )) || return $rc
  fi
  eval "$_herdr_claude_plain \"\$@\""
}

# Reattach a Claude Code session running in herdr (ctrl+b q detaches).
cattach() { "$_herdr_claude_bin/cattach" "$@" }
